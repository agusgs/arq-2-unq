defmodule WeatherFlow.Application.Services.StationManagementServiceTest do
  use ExUnit.Case, async: false

  alias WeatherFlow.Application.Services.StationManagementService
  alias WeatherFlow.Domain.Station
  alias WeatherFlow.Adapters.MongoStationRepository

  setup do
    Mongo.delete_many!(:mongo, "stations", %{})
    MongoStationRepository.setup_indexes()
    :ok
  end

  describe "register_station/1" do
    test "registra exitosamente una estación devolviendo su ID" do
      attrs = %{"name" => "Estación Central", "latitude" => -34.0, "longitude" => -58.0}

      assert {:ok, %Station{} = station} = StationManagementService.register_station(attrs)
      assert station.name == "Estación Central"
      assert station.latitude == -34.0
      assert station.longitude == -58.0
      assert is_binary(station.id)
    end

    test "falla si los atributos son inválidos (dominio puro)" do
      attrs = %{"name" => "", "latitude" => -34.0, "longitude" => -58.0}
      assert {:error, "El nombre de la estación es obligatorio."} = StationManagementService.register_station(attrs)
    end

    test "falla si se intenta registrar una estación con un nombre duplicado en BD" do
       attrs = %{"name" => "Estación Única", "latitude" => -34.0, "longitude" => -58.0}
       assert {:ok, _} = StationManagementService.register_station(attrs)
       
       # El segundo registro choca con el índice de MongoDB directamente
       assert {:error, "El nombre de la estación ya se encuentra registrado."} = StationManagementService.register_station(attrs)
    end
  end

  describe "list_stations/0" do
    test "retorna lista vacía si la coleccion BSON no tiene nada" do
      assert {:ok, []} = StationManagementService.list_stations()
    end

    test "retorna todas las estaciones almacenadas" do
      StationManagementService.register_station(%{"name" => "Sur", "latitude" => -40.0, "longitude" => -60.0})
      StationManagementService.register_station(%{"name" => "Norte", "latitude" => -20.0, "longitude" => -60.0})

      assert {:ok, stations} = StationManagementService.list_stations()
      assert length(stations) == 2
    end
  end

  describe "get_station/1" do
    test "retorna :not_found si el objectId no existe en Mongo o es inválido" do
       assert {:error, :not_found} = StationManagementService.get_station("123456789012345678901234")
       assert {:error, :not_found} = StationManagementService.get_station("id_corta_invalida")
    end
    
    test "retorna la estación correctamente por ID real" do
      attrs = %{"name" => "Estación Este", "latitude" => -10.0, "longitude" => -40.0}
      {:ok, %Station{id: id}} = StationManagementService.register_station(attrs)

      assert {:ok, %Station{} = fetched} = StationManagementService.get_station(id)
      assert fetched.id == id
      assert fetched.name == "Estación Este"
    end
  end
end

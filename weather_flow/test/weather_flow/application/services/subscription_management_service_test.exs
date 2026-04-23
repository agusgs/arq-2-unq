defmodule WeatherFlow.Application.Services.SubscriptionManagementServiceTest do
  use WeatherFlow.DataCase, async: false

  alias WeatherFlow.Application.Services.SubscriptionManagementService
  alias WeatherFlow.Adapters.{MongoUserRepository, MongoStationRepository}
  alias WeatherFlow.Domain.{User, Station}

  setup do
    {:ok, %User{} = valid_user} =
      MongoUserRepository.insert(%User{
        first_name: "A",
        last_name: "B",
        email: "sub@test.com",
        subscriptions: []
      })

    {:ok, %Station{} = valid_station} =
      MongoStationRepository.insert(%Station{
        name: "EstacionCentral",
        latitude: -30.0,
        longitude: -50.0
      })

    {:ok, user: valid_user, station: valid_station}
  end

  describe "subscribe/2" do
    test "suscribe correctamente a un usuario a una estación", %{user: user, station: station} do
      assert {:ok, result_user} = SubscriptionManagementService.subscribe(user.id, station.id)
      assert result_user.subscriptions == [station.id]

      # Vemos si persistió
      {:ok, user_bd} = MongoUserRepository.get_by_id(user.id)
      assert user_bd.subscriptions == [station.id]
    end

    test "falla si la estación no existe", %{user: user} do
      assert {:error, :not_found} =
               SubscriptionManagementService.subscribe(user.id, "66144e5b3dc8a6efb349b1aa")
    end

    test "falla si el usuario no existe", %{station: station} do
      assert {:error, :not_found} =
               SubscriptionManagementService.subscribe("66144e5b3dc8a6efb349b1aa", station.id)
    end
  end

  describe "unsubscribe/2" do
    test "remueve la suscripción exitosamente", %{user: user, station: station} do
      {:ok, subbed_user} = SubscriptionManagementService.subscribe(user.id, station.id)
      assert subbed_user.subscriptions == [station.id]

      {:ok, unsubbed_user} = SubscriptionManagementService.unsubscribe(subbed_user.id, station.id)
      assert unsubbed_user.subscriptions == []

      # Persistencia
      {:ok, user_bd} = MongoUserRepository.get_by_id(user.id)
      assert user_bd.subscriptions == []
    end

    test "falla si el usuario no existe al intentar desuscribir", %{station: station} do
      assert {:error, :not_found} =
               SubscriptionManagementService.unsubscribe("66144e5b3dc8a6efb349b1aa", station.id)
    end
  end
end

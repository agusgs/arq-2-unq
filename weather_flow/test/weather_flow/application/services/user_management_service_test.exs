defmodule WeatherFlow.Application.Services.UserManagementServiceTest do
  use ExUnit.Case, async: false

  alias WeatherFlow.Application.Services.UserManagementService
  alias WeatherFlow.Adapters.MongoUserRepository

  setup do
    Mongo.delete_many!(:mongo, "users", %{})
    MongoUserRepository.setup_indexes()
    :ok
  end

  describe "register_user/1" do
    test "registra usuario con datos validos impactando en MongoDB" do
      attrs = %{"first_name" => "Juan", "last_name" => "Perez", "email" => "juan@test.com"}
      assert {:ok, user} = UserManagementService.register_user(attrs)
      assert user.id != nil
      assert user.email == "juan@test.com"
    end

    test "falla si no se proporciona first_name" do
      attrs = %{"last_name" => "Perez", "email" => "juan@test.com"}
      assert {:error, msg} = UserManagementService.register_user(attrs)
      assert msg =~ "requeridos"
    end

    test "falla si no se proporciona last_name" do
      attrs = %{"first_name" => "Juan", "email" => "juan@test.com"}
      assert {:error, msg} = UserManagementService.register_user(attrs)
      assert msg =~ "requeridos"
    end

    test "falla si no se proporciona email" do
      attrs = %{"first_name" => "Juan", "last_name" => "Perez"}
      assert {:error, msg} = UserManagementService.register_user(attrs)
      assert msg =~ "requeridos"
    end

    test "falla si se intenta registrar el mismo email, atajando la validacion de Mongo" do
      attrs = %{"first_name" => "User", "last_name" => "Test", "email" => "duplicate@example.com"}
      assert {:ok, _} = UserManagementService.register_user(attrs)

      assert {:error, "El email ya se encuentra registrado."} =
               UserManagementService.register_user(attrs)
    end
  end

  describe "list_users/0" do
    test "retorna lista vacía si la coleccion BSON no tiene nada" do
      assert UserManagementService.list_users() == []
    end

    test "retorna los usuarios cuando se insertaron con exito" do
      attrs = %{"first_name" => "Juan", "last_name" => "Perez", "email" => "juan@test.com"}
      {:ok, _} = UserManagementService.register_user(attrs)

      list = UserManagementService.list_users()
      assert length(list) == 1
      assert hd(list).first_name == "Juan"
    end
  end

  describe "get_user/1" do
    test "retorna :not_found si el objectId no existe en Mongo" do
      assert {:error, :not_found} = UserManagementService.get_user("123456789012345678901234")
    end

    test "retorna :not_found silencioso si es un HexString defectuoso" do
      assert {:error, :not_found} = UserManagementService.get_user("invalid_id_corta")
    end

    test "obtiene el usuario del adaptador Mongo de forma precisa filtrando por Object ID" do
      attrs = %{"first_name" => "Marta", "last_name" => "Gomez", "email" => "marta@test.com"}
      {:ok, inserted_user} = UserManagementService.register_user(attrs)

      assert {:ok, user} = UserManagementService.get_user(inserted_user.id)
      assert user.first_name == "Marta"
      assert user.email == "marta@test.com"
    end
  end
end

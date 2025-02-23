defmodule AppWeb.AuthController do
  alias App.Auth
  use AppWeb, :controller

  defmodule SignInContract do
    use Drops.Contract

    schema(atomize: true) do
      %{
        required(:email) => string(:filled?),
        required(:password) => string(:filled?)
      }
    end
  end

  def sign_in(conn, unsafe_params) do
    with {:ok, params} <- SignInContract.conform(unsafe_params) do
      _request_log = App.Logs.create_request_log!(:sign_in, params)


      case App.Auth.sign_in(%{email: params.email, password: params.password}) do
        {:ok, user_id} -> json(conn, %{user_id: user_id})
        {:error, error} -> json(conn, %{msg: error})
      end
    end
  end

  defmodule SignUpContract do
    use Drops.Contract

    schema(atomize: true) do
      %{
        required(:email) => string(:filled?),
        required(:password) => string(:filled?),
        required(:username) => string(:filled?),
        required(:phone) => string(:filled?),
        required(:name) => string(:filled?),
        required(:surname) => string(:filled?)
      }
    end
  end

  def sign_up(conn, unsafe_params) do
    with {:ok, params} <- SignUpContract.conform(unsafe_params) do
      _request_log = App.Logs.create_request_log!(:sign_up, params)

      case Auth.sign_up(params) do
        {:ok, user_id} ->
          json(conn, %{user_id: user_id})

        {:error, error} ->
          json(conn, %{error: error})
      end
    end
  end
end

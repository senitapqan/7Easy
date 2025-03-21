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
      case App.Auth.sign_in(%{email: params.email, password: params.password}) do
        {:ok, token} ->
          json(conn, %{token: token})

        {:error, error} ->
          conn
          |> put_status(401)
          |> json(%{msg: error})
      end
    end
  end

  defmodule SignUpContract do
    use Drops.Contract

    schema(atomize: true) do
      %{
        required(:email) => string(:filled?),
        required(:password) => string(:filled?)
      }
    end
  end

  def sign_up(conn, unsafe_params) do
    with {:ok, params} <- SignUpContract.conform(unsafe_params) do

      case Auth.sign_up(params) do
        {:ok, user_id} ->
          json(conn, %{user_id: user_id})

        {:error, error} ->
          json(conn, %{error: error})
      end
    end
  end
end

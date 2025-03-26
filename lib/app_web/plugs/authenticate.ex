defmodule AppWeb.Plugs.Authenticate do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    conn
    |> get_auth_token()
    |> App.Auth.verify_token()
    |> case do
      {:ok, user_id} ->
        assign(conn, :user_id, user_id)

      false ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Unauthorized"})
        |> halt()
    end
  end

  defp get_auth_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> token
      _ -> nil
    end
  end
end

defmodule AppWeb.Plugs.Authenticate do
  import Plug.Conn

  defp access_token, do: Application.fetch_env!(:app, :easy_seven_access_token)

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    conn
    |> get_auth_token()
    |> constant_time_compare(access_token())
    |> case do
      true ->
        conn

      false ->
        conn
        |> put_status(:unauthorized)
        |> halt()
    end
  end

  defp get_auth_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> token
      _ -> nil
    end
  end

  defp constant_time_compare(request_token, access_token) do
    do_constant_time_compare(String.to_charlist(request_token), String.to_charlist(access_token), true)
  end

  defp do_constant_time_compare([], [], result), do: result

  defp do_constant_time_compare([head1 | tail1], [head2 | tail2], result) do
    new_result = result and head1 == head2
    do_constant_time_compare(tail1, tail2, new_result)
  end

  defp do_constant_time_compare(_, _, _), do: false
end

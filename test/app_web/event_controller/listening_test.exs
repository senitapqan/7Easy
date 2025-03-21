defmodule AppWeb.EventController.ListeningTest do
  use AppWeb.ConnCase

  import App.Factory
  setup do
    insert(:user, email: "maskeugalievd@gmail.com", password: Bcrypt.hash_pwd_salt("qwerty"))

    params = %{
      email: "maskeugalievd@gmail.com",
      password: "qwerty"
    }

    response =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> post("/auth/sign_in", params)

    {:ok, result} = Jason.decode(response.resp_body)
    %{token: result["token"]}
  end

  def request(token, request_type, path) do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> do_request(request_type, path)
  end

  def do_request(conn, "get", path) do
    conn
    |> get(path)
    |> json_response(200)
  end

  def do_request(conn, "post", path, params) do
    conn
    |> post(path, params)
    |> json_response(200)
  end

  test "get listening test returns 200", %{token: token} do
    response = request(token, "get", "/api/test?type=listening")
    assert response.status == 200
  end
end

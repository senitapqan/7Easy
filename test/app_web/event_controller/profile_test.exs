defmodule AppWeb.EventControllerTest.ProfileTest do
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

  def do_request(token) do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> get("/api/profile")
  end

  test "profile", %{token: token} do
    response = do_request(token)

    assert response.status == 200
    dbg(Jason.decode!(response.resp_body))
  end
end

defmodule AppWeb.EventController.ReadingTestTest do
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

  def do_request(token, type) do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> get("/api/test?type=#{type}")
  end


  test "returns 200", %{token: token} do
    response = do_request(token, "reading")
    assert response.status == 200
  end

  test "returns 401" do
    response = do_request("invalid_token", "reading")
    assert response.status == 401
  end

end

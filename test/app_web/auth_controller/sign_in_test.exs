defmodule AppWeb.AuthControllerTest.SignInTest do
  use AppWeb.ConnCase

  import App.Factory

  def do_request() do
    params = %{
      email: "maskeugalievd@gmail.com",
      password: "qwerty"
    }

    build_conn()
    |> put_req_header("accept", "application/json")
    |> post("/auth/sign_in", params)
  end

  test "returns 200" do
    insert(:user, email: "maskeugalievd@gmail.com", password: Bcrypt.hash_pwd_salt("qwerty"))

    response = do_request()

    {:ok, result} = Jason.decode(response.resp_body)
    assert json_response(response, 200) == result
  end

  test "response 401" do
    response = do_request()
    assert json_response(response, 401) == %{"msg" => "invalid_credentials"}
  end
end

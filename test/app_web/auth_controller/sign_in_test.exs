defmodule AppWeb.AuthControllerTest.SignInTest do
  use AppWeb.ConnCase
  import App.Factory

  def do_request(params \\ %{}) do
    params =
      Map.merge(
        %{
          email: "maskeugalievd@gmail.com",
          password: "qwerty"
        },
        params
      )

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

  test "response 401 when user not found" do
    response = do_request()
    assert json_response(response, 401) == %{"error" => "invalid_credentials"}
  end

  test "response 401 when password is incorrect" do
    insert(:user, email: "maskeugalievd@gmail.com", password: Bcrypt.hash_pwd_salt("qwerty"))

    response = do_request(%{password: "wrong_password"})
    assert json_response(response, 401) == %{"error" => "invalid_credentials"}
  end
end

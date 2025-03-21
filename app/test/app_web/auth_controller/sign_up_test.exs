defmodule AppWeb.AuthControllerTest do
  use AppWeb.ConnCase

  import App.Factory
  alias App.Schemas.User

  def do_request() do
    params = %{
      email: "test@test.com",
      password: "password"
    }

    build_conn()
    |> put_req_header("accept", "application/json")
    |> post("/auth/sign_up", params)
  end

  test "returns 200" do
    response = do_request()
    {:ok, result} = Jason.decode(response.resp_body)

    assert App.Repo.exists?(User)
    assert json_response(response, 200) == result
  end

  test "user with same email already exists" do
    insert(:user, email: "test@test.com")

    response = do_request()
    assert json_response(response, 400) == %{"msg" => "email_already_exists"}
  end
end

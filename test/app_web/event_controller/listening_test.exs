defmodule AppWeb.EventController.ListeningTest do
  use AppWeb.ConnCase

  alias App.Repo
  alias App.Schemas.ListeningResult
  alias App.Schemas.User

  require Ecto.Query

  setup do
    user = insert(:user, email: "maskeugalievd@gmail.com", password: Bcrypt.hash_pwd_salt("qwerty"))

    listening = insert(:listening_test)
    question = insert(:question, test_id: listening.id, test_type: "listening")

    params = %{
      email: "maskeugalievd@gmail.com",
      password: "qwerty"
    }

    response =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> post("/auth/sign_in", params)

    listening_params = %{
      test_type: "listening",
      test_id: listening.id,
      answers: [
        %{
          question_id: question.id,
          answer: question.correct_answer
        }
      ]
    }

    {:ok, result} = Jason.decode(response.resp_body)

    %{
      token: result["token"],
      user_id: user.id,
      listening: listening,
      params: listening_params
    }
  end

  def request(token, request_type, path, params \\ %{}) do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> do_request(request_type, path, params)
  end

  def do_request(conn, "get", path, _params) do
    get(
      conn,
      path
    )
  end

  def do_request(conn, "post", path, params) do
    post conn, path, params
  end

  test "get tests", %{token: token} do
    response = request(token, "get", "/api/tests?type=listening")
    assert response.status == 200
    dbg(Jason.decode!(response.resp_body))
  end

  test "get test", %{token: token, listening: listening} do
    response = request(token, "get", "/api/test?type=listening&test_id=#{listening.id}")
    assert response.status == 200
    dbg(Jason.decode!(response.resp_body))
  end

  test "saves test result", %{token: token, user_id: user_id, params: params} do
    listening_id = params.test_id

    response = request(token, "post", "/api/test/save", params)
    assert response.status == 200

    assert Repo.exists?(
             Ecto.Query.from(r in ListeningResult, where: r.user_id == ^user_id and r.listening_id == ^listening_id)
           )
  end

  test "updates user score", %{token: token, user_id: user_id, params: params} do
    old_score = Repo.get(User, user_id).avg_listening_score
    response = request(token, "post", "/api/test/save", params)
    assert response.status == 200
    new_score = Repo.get(User, user_id).avg_listening_score
    assert new_score != old_score
  end

  test "returns history", %{token: token, params: params} do
    request(token, "post", "/api/test/save", params)

    response = request(token, "get", "/api/test/history?type=listening&result_id=#{params.test_id}")
    assert response.status == 200
    dbg(Jason.decode!(response.resp_body))
  end
end

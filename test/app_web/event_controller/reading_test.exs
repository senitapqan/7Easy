defmodule AppWeb.EventController.ReadingTestTest do
  use AppWeb.ConnCase
  import App.Factory

  alias App.Repo
  alias App.Schemas.ReadingResult
  alias App.Schemas.User

  require Ecto.Query

  setup do
    user = insert(:user, email: "maskeugalievd@gmail.com", password: Bcrypt.hash_pwd_salt("qwerty"))

    reading = insert(:reading_test)
    question = insert(:question, test_id: reading.id, test_type: "reading")

    params = %{
      email: "maskeugalievd@gmail.com",
      password: "qwerty"
    }

    reading_params = %{
      test_type: "reading",
      test_id: reading.id,
      answers: [
        %{
          question_id: question.id,
          answer: question.correct_answer
        }
      ]
    }

    response =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> post("/auth/sign_in", params)

    {:ok, result} = Jason.decode(response.resp_body)

    %{
      token: result["token"],
      user_id: user.id,
      reading: reading,
      params: reading_params
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
    post(conn, path, params)
  end

  test "get tests", %{token: token} do
    response = request(token, "get", "/api/tests?type=reading")
    assert response.status == 200
    dbg(Jason.decode!(response.resp_body))
  end

  test "get test", %{token: token, reading: reading} do
    response = request(token, "get", "/api/test?type=reading&test_id=#{reading.id}")
    assert response.status == 200
    dbg(Jason.decode!(response.resp_body))
  end

  test "saves test result", %{token: token, user_id: user_id, params: params} do
    reading_id = params.test_id

    response = request(token, "post", "/api/test/save", params)
    assert response.status == 200

    assert Repo.exists?(
             Ecto.Query.from(r in ReadingResult, where: r.user_id == ^user_id and r.reading_id == ^reading_id)
           )
  end

  test "updates user score", %{token: token, user_id: user_id, params: params} do
    old_score = Repo.get(User, user_id).avg_reading_score
    response = request(token, "post", "/api/test/save", params)
    assert response.status == 200
    new_score = Repo.get(User, user_id).avg_reading_score
    assert new_score != old_score
  end

  test "returns history", %{token: token, params: params} do
    request(token, "post", "/api/test/save", params)
    response = request(token, "get", "/api/test/history?type=reading&test_id=#{params.test_id}")
    assert response.status == 200
    dbg(Jason.decode!(response.resp_body))
  end
end

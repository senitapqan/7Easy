defmodule AppWeb.EventController.SaveTestTest do
  use AppWeb.ConnCase

  alias App.Tests.Schemas.Results.ReadingResult
  alias App.Repo

  import App.Factory
  require Ecto.Query

  setup do
    user = insert(:user, email: "maskeugalievd@gmail.com", password: Bcrypt.hash_pwd_salt("qwerty"))
    reading_test = insert(:reading_test)
    question = insert(:question, test: reading_test)

    params = %{
      email: "maskeugalievd@gmail.com",
      password: "qwerty"
    }

    response =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> post("/auth/sign_in", params)

    {:ok, result} = Jason.decode(response.resp_body)

    %{
      token: result["token"],
      reading_test: reading_test,
      question_id: question.id,
      user_id: user.id
    }
  end

  def do_request(token, type, test_id, question_id) do
    params = %{
      "test_type" => type,
      "test_id" => test_id,
      "answers" => [
        %{
          "question_id" => question_id,
          "answer" => "London"
        }
      ]
    }

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/api/tests/save", params)
  end

  test "returns 200", %{token: token, reading_test: reading_test, question_id: question_id} do
    response = do_request(token, "reading", reading_test.id, question_id)

    assert response.status == 200
  end

  test "saves result", %{token: token, reading_test: reading_test, question_id: question_id, user_id: user_id} do
    do_request(token, "reading", reading_test.id, question_id)

    result = Repo.one(Ecto.Query.from(r in ReadingResult, where: r.user_id == ^user_id))
    assert Repo.exists?(ReadingResult)
  end
end

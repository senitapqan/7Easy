defmodule AppWeb.EventController.SpeakingTest do
  alias App.Repo
  alias App.Schemas.Speaking
  alias App.Schemas.SpeakingQuestion
  alias App.Schemas.SpeakingTestQuestion

  use AppWeb.ConnCase

  setup do
    password = Bcrypt.hash_pwd_salt("qwerty")
    user = insert(:user, email: "maskeugalievd@gmail.com", password: password)
    token = sign_in(user)

    audio_file = %Plug.Upload{
      path: "/Users/senitapqan/Desktop/elixir/7Easy/test/support/fixtures/my_short_audio.m4a",
      filename: "my_short_audio.m4a",
      content_type: "audio/mp4"
    }

    %{
      user: user,
      token: token,
      audio_file: audio_file
    }
  end

  defp sign_in(user) do
    params = %{
      email: user.email,
      password: "qwerty"
    }

    response =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> post("/auth/sign_in", params)

    {:ok, result} = Jason.decode(response.resp_body)

    result["token"]
  end

  describe "contracts" do
    test "continue_speaking with valid params" do
    end

    test "continue_speaking with wrong params" do
    end

    test "save_speaking with valid params" do
    end

    test "save_speaking with wrong params" do
    end
  end

  def start_speaking(token) do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
    |> get("/api/speaking/start")
  end

  describe "start speaking" do
    test "returns 200", %{token: token} do
      response = start_speaking(token)

      assert response.status == 200
    end

    test "saves speaking test", %{token: token} do
      start_speaking(token)

      assert Repo.exists?(Speaking)
    end

    test "updates speaking test status to started", %{token: token} do
      start_speaking(token)

      assert Repo.get_by(Speaking, status: "started") != nil
    end

    test "saves questions to db", %{token: token} do
      start_speaking(token)

      assert Repo.exists?(SpeakingTestQuestion)
    end

    test "relates user to speaking test", %{user: user, token: token} do
      start_speaking(token)

      assert Repo.get_by(Speaking, status: "started", user_id: user.id) != nil
    end

    test "returns json with speaking questions", %{token: token} do
      response = start_speaking(token)

      dbg(Jason.decode!(response.resp_body))

      assert response.status == 200
      assert response.resp_body != ""
    end
  end

  def continue_speaking(file, token, speaking_id) do
    params = %{
      test_type: "speaking",
      speaking_id: speaking_id,
      answers: [
        %{
          question_id: "1",
          audio_file: file
        }
      ]
    }

    build_conn()
    |> put_req_header("authorization", "Bearer #{token}")
    |> post("/api/speaking/continue", params)
  end

  describe "continue speaking" do
    setup context do
      stub_with(App.MockS3, App.StubS3)
      stub_with(App.MockGpt, App.StubGpt)
      stub_with(App.MockSpeechToText, App.StubSpeechToText)

      user = context.user
      speaking = insert(:speaking_test, user_id: user.id)
      question = insert(:speaking_question)
      insert(:speaking_test_question, speaking_id: speaking.id, speaking_question_id: question.id)

      Map.put(context, :speaking, speaking)
    end

    test "returns 200", %{token: token, audio_file: audio_file, speaking: speaking} do
      response = continue_speaking(audio_file, token, speaking.id)

      assert response.status == 200
    end

    test "saves answers to s3", %{token: token, audio_file: audio_file, speaking: speaking} do
      expect(App.MockS3, :upload_file!, fn _, _, _ -> "path" end)
      continue_speaking(audio_file, token, speaking.id)
    end

    test "generates part 3 questions", %{token: token, audio_file: audio_file, speaking: speaking} do
      expect(App.MockGpt, :generate_speaking_question, fn _ -> {:ok, [%SpeakingQuestion{}]} end)
      continue_speaking(audio_file, token, speaking.id)
    end

    test "saves part 3 questions to db", %{token: token, audio_file: audio_file, speaking: speaking} do
      Mox.expect(App.MockGpt, :generate_speaking_question, fn _ ->
        {:ok, [%SpeakingQuestion{id: "1", question: "What is the capital of France?", part: 3, test_type: "speaking"}]}
      end)

      continue_speaking(audio_file, token, speaking.id)
      assert Repo.exists?(SpeakingTestQuestion)
    end

    test "return 404 if user have no access to speaking test", %{token: token, audio_file: audio_file} do
      user = insert(:user)
      speaking = insert(:speaking_test, user_id: user.id)
      question = insert(:speaking_question)
      insert(:speaking_test_question, speaking_id: speaking.id, speaking_question_id: question.id)

      response = continue_speaking(audio_file, token, speaking.id)

      assert response.status == 404
    end

    test "returns 404 if speaking test not found", %{token: token, audio_file: audio_file, speaking: speaking} do
      response = continue_speaking(audio_file, token, speaking.id + 1)

      assert response.status == 404
    end

    test "returns 502 if transcription failed", %{token: token, audio_file: audio_file, speaking: speaking} do
      expect(App.MockSpeechToText, :get_operation_result, fn _ -> {:error, :transcription_failed} end)
      response = continue_speaking(audio_file, token, speaking.id)

      assert response.status == 502
    end

    test "returns 502 if http error", %{token: token, audio_file: audio_file, speaking: speaking} do
      expect(App.MockSpeechToText, :get_operation_result, fn _ -> {:error, {:http_error, "error"}} end)
      response = continue_speaking(audio_file, token, speaking.id)

      assert response.status == 502
    end

    test "returns 502 if invalid json", %{token: token, audio_file: audio_file, speaking: speaking} do
      expect(App.MockSpeechToText, :get_operation_result, fn _ -> {:error, {:invalid_json, "error"}} end)
      response = continue_speaking(audio_file, token, speaking.id)

      assert response.status == 502
    end
  end

  def save_speaking() do
    conn = build_conn()
  end

  describe "save speaking" do
    test "returns 200" do
    end

    test "gives mark for speaking" do
    end

    test "gives feedback for speaking" do
    end

    test "returns 404 if speaking test not found" do
    end

    test "returns 401 if user have no access to speaking test" do
    end

    test "saves speaking result" do
    end
  end
end

defmodule App.OpenAi.GptTest do
  alias App.Schemas.SpeakingQuestion
  alias App.Schemas.Writing
  alias App.Schemas.WritingResult

  use ExUnit.Case, async: true

  describe "Works with real API" do
    @describetag :live_network
    setup do
      old_env = Application.get_env(:seven_easy, :gpt_client)
      Application.put_env(:seven_easy, :gpt_client, App.OpenAi.GptClient)

      on_exit(fn ->
        Application.put_env(:seven_easy, :gpt_client, old_env)
      end)
    end

    test "generate essay returns valid writing" do
      assert {:ok, %Writing{} = result} = App.OpenAi.Gpt.generate_essay()
      dbg(result)
    end

    test "mark essay returns valid writing result" do
      question = File.read!("test/support/fixtures/writing_question.txt")

      essay = File.read!("test/support/fixtures/writing_essay.txt")
      assert {:ok, %WritingResult{} = result} = App.OpenAi.Gpt.mark_essay(essay, question)
      dbg(result)
    end

    test "generate speaking question returns valid speaking question" do
      question1 = File.read!("test/support/fixtures/speaking/question1.txt")
      question2 = File.read!("test/support/fixtures/speaking/question2.txt")
      question3 = File.read!("test/support/fixtures/speaking/question3.txt")
      answer1 = File.read!("test/support/fixtures/speaking/answer1.txt")
      answer2 = File.read!("test/support/fixtures/speaking/answer2.txt")
      answer3 = File.read!("test/support/fixtures/speaking/answer3.txt")

      content = [
        %{question: question1, answer: answer1},
        %{question: question2, answer: answer2},
        %{question: question3, answer: answer3}
      ]

      assert {:ok, [%SpeakingQuestion{} | _] = result} = App.OpenAi.Gpt.generate_speaking_question(content)
      dbg(result)
    end

    test "mark speaking returns valid speaking result" do
      question1 = File.read!("test/support/fixtures/speaking/question1.txt")
      question2 = File.read!("test/support/fixtures/speaking/question2.txt")
      question3 = File.read!("test/support/fixtures/speaking/question3.txt")
      question4 = File.read!("test/support/fixtures/speaking/question4.txt")
      question5 = File.read!("test/support/fixtures/speaking/question5.txt")
      answer1 = File.read!("test/support/fixtures/speaking/answer1.txt")
      answer2 = File.read!("test/support/fixtures/speaking/answer2.txt")
      answer3 = File.read!("test/support/fixtures/speaking/answer3.txt")
      answer4 = File.read!("test/support/fixtures/speaking/answer4.txt")
      answer5 = File.read!("test/support/fixtures/speaking/answer5.txt")

      content = [
        %{question: question1, answer: answer1},
        %{question: question2, answer: answer2},
        %{question: question3, answer: answer3},
        %{question: question4, answer: answer4},
        %{question: question5, answer: answer5}
      ]

      assert {:ok, result} = App.OpenAi.Gpt.mark_speaking_test(content)
      dbg(result)
    end
  end
end

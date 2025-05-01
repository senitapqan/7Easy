defmodule App.Speaking.ContinueSpeaking do
  alias App.OpenAi.Gpt
  alias App.Parser.SpeakingParser
  alias App.Speaking.Shared
  alias App.SpeakingContext

  def continue_speaking(user_id, speaking_id, content) do
    speaking = SpeakingContext.get_speaking_test(speaking_id)

    with :ok <- validate_speaking(speaking, content, user_id) do
      do_continue_speaking(speaking, content, user_id)
    end
  end

  defp do_continue_speaking(speaking, content, user_id) do
    speaking_result =
      SpeakingContext.create_speaking_result!(%{
        speaking_id: speaking.id,
        user_id: user_id
      })

    result_content = Shared.user_answers(content, user_id, speaking.id)

    with {:ok, result_content} <- Shared.validate_result_content(result_content),
         {:ok, questions_part_3} <- generate_third_part_question(result_content) do
      SpeakingContext.update_speaking_result!(speaking_result, %{
        content: result_content
      })

      questions_part_3 =
        Enum.map(questions_part_3, fn question ->
          SpeakingContext.create_speaking_question!(%{
            question: question.question,
            sub_questions: question.sub_questions,
            part: question.part,
            test_type: question.test_type
          })
        end)

      SpeakingContext.insert_questions_to_speaking(speaking.id, questions_part_3)

      SpeakingContext.update_speaking!(speaking, %{
        question_count: speaking.question_count + length(questions_part_3)
      })

      {:ok, SpeakingParser.parse_questions(questions_part_3)}
    end
  end

  defp generate_third_part_question(content) do
    case Gpt.generate_speaking_question(content) do
      {:ok, question} ->
        {:ok, question}

      {:error, error} ->
        {:error, error}
    end
  end

  defp validate_speaking(speaking, content, user_id) do
    cond do
      speaking == nil -> {:error, :speaking_not_found}
      speaking.user_id != user_id -> {:error, :user_didnt_pass_test}
      speaking.status != "started" -> {:error, :speaking_not_started}
      speaking.question_count != length(content) -> {:error, :invalid_number_of_answers}
      true -> :ok
    end
  end
end

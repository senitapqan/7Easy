defmodule App.Speaking.SaveSpeaking do
  alias App.OpenAi.Gpt
  alias App.Speaking.Shared
  alias App.SpeakingContext
  alias App.Users

  def save_speaking(user_id, speaking_id, content) do
    speaking_result = SpeakingContext.get_speaking_result_by_speaking_id(speaking_id, preload: [:speaking])

    with {:ok, speaking} <- validate_speaking_result(speaking_result, content, user_id) do
      do_save_speaking(speaking_result, speaking, content)
    end
  end

  defp do_save_speaking(speaking_result, speaking, content) do
    result_content = Shared.user_answers(content, speaking_result.user_id, speaking_result.speaking_id)

    with {:ok, result_content} <- Shared.validate_result_content(result_content),
         result_content = normalize_result_content(speaking_result.content) ++ result_content,
         {:ok, test_mark} <- mark_speaking_test(result_content) do
      speaking_result =
        SpeakingContext.update_speaking_result!(speaking_result, %{
          content: result_content,
          score: test_mark["score"],
          strengths: test_mark["strengths"],
          areas_for_improvement: test_mark["areas_for_improvement"],
          recommendations: test_mark["recommendations"]
        })

      Users.update_avg_score(speaking_result.user_id, :speaking, test_mark["score"])

      SpeakingContext.update_speaking!(speaking, %{
        status: "completed"
      })

      {:ok, test_mark}
    end
  end

  defp mark_speaking_test(result_content) do
    Gpt.mark_speaking_test(result_content)
  end

  defp normalize_result_content(content) do
    Enum.map(content, fn item ->
      %{
        question: Map.get(item, "question"),
        question_id: Map.get(item, "question_id"),
        sub_questions: Map.get(item, "sub_questions"),
        file_url: Map.get(item, "file_url"),
        transcript: Map.get(item, "transcript")
      }
    end)
  end

  defp validate_speaking_result(speaking_result, content, user_id) do
    # I have added +3 because we have 3 questions in the first and second parts
    cond do
      speaking_result == nil -> {:error, :result_not_found}
      speaking_result.speaking.status == "completed" -> {:error, :speaking_completed}
      speaking_result.speaking.user_id != user_id -> {:error, :user_didnt_pass_test}
      speaking_result.speaking.question_count != length(content) + 3 -> {:error, :invalid_number_of_answers}
      true -> {:ok, speaking_result.speaking}
    end
  end
end

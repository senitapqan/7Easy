defmodule App.Speaking.ContinueSpeaking do
  alias App.Assembly.SpeechToText
  alias App.Files
  alias App.OpenAi.Gpt
  alias App.Parser.SpeakingParser
  alias App.SpeakingContext

  def continue_speaking(user_id, speaking_id, content) do
    speaking = SpeakingContext.get_speaking_test!(speaking_id, filters: [user_id: user_id, status: "started"])
    do_continue_speaking(speaking, content, user_id)
  end

  defp do_continue_speaking(nil, _content, _user_id) do
    {:error, :speaking_not_found}
  end

  defp do_continue_speaking(speaking, content, user_id) do
    speaking_result =
      SpeakingContext.create_speaking_result!(%{
        speaking_id: speaking.id,
        user_id: user_id
      })

    result_content = user_answers(content.answers, user_id, speaking.id)

    with {:ok, result_content} <- validate_result_content(result_content),
         {:ok, questions_part_3} <- generate_third_part_question(result_content) do
      SpeakingContext.update_speaking_result!(speaking_result, %{
        content: result_content
      })

      {:ok, Enum.map(questions_part_3, &SpeakingParser.parse_question/1)}
    end
  end

  defp user_answers(answers, user_id, speaking_id) do
    answers
    |> Task.async_stream(fn answer ->
      question_id = answer.question_id
      file_url = Files.upload_file!(user_id, speaking_id, question_id, answer.audio_file, "mp4")
      result = audio_to_text(answer.audio_file)

      case result do
        {:ok, transcript} ->
          {:ok,
           %{
             question_id: question_id,
             file_url: file_url,
             transcript: transcript
           }}

        {:error, reason} ->
          {:error, reason}
      end
    end)
    |> Enum.map(fn
      {:ok, {:ok, data}} -> data
      {:ok, {:error, error}} -> {:error, error}
      {:exit, reason} -> {:error, reason}
    end)
  end

  defp audio_to_text(audio_file) do
    with {:ok, operation_id} <- SpeechToText.recognize(audio_file),
         {:ok, transcript} <- get_operation_result(operation_id) do
      {:ok, transcript}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_operation_result(operation_id, attempts \\ 5) do
    case SpeechToText.get_operation_result(operation_id) do
      {:ok, text} ->
        {:ok, text}

      {:pending, :still_processing} ->
        if attempts > 0 do
          :timer.sleep(1000)
          get_operation_result(operation_id, attempts - 1)
        else
          {:error, :timeout}
        end

      {:error, error} ->
        {:error, error}
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

  defp validate_result_content(result_content) do
    errors = Enum.filter(result_content, fn
      %{} = map -> Map.has_key?(map, :error)
      {:error, _reason} -> true
      _ -> false
    end)

    if Enum.empty?(errors) do
      {:ok, result_content}
    else
      hd(errors)
    end
  end
end

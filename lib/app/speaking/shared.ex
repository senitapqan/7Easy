defmodule App.Speaking.Shared do
  alias App.Assembly.SpeechToText
  alias App.Files
  alias App.SpeakingContext

  def user_answers(answers, user_id, speaking_id) do
    answers
    |> Task.async_stream(
      fn answer ->
        question = SpeakingContext.get_speaking_question!(answer.question_id)
        file_url = Files.upload_file!(user_id, speaking_id, question.id, answer.audio_file, "mp4")
        result = audio_to_text(answer.audio_file)

        case result do
          {:ok, transcript} ->
            {:ok,
             %{
               question_id: question.id,
               question: question.question,
               sub_questions: question.sub_questions,
               file_url: file_url,
               transcript: transcript
             }}

          {:error, reason} ->
            {:error, reason}
        end
      end,
      timeout: 20000
    )
    |> Enum.map(fn
      {:ok, {:ok, data}} -> data
      {:ok, {:error, error}} -> {:error, error}
      {:exit, reason} -> {:error, reason}
    end)
  end

  def validate_result_content(result_content) do
    errors =
      Enum.filter(result_content, fn
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
end

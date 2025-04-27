defmodule App.OpenAi.GptParser do
  alias App.Schemas.SpeakingQuestion
  alias App.Schemas.Writing
  alias App.Schemas.WritingResult

  def parse_essay_task(json) do
    content = get_content!(json)
    {:ok, %Writing{task: content}}
  end

  def parse_essay_mark(json) do
    content = get_content!(json)

    with {:ok, params} <- parse_json_text(content) do
      {:ok,
       %WritingResult{
         score: params["score"],
         grammar_feedback: params["grammar"],
         vocabulary_feedback: params["vocabulary"],
         structure_feedback: params["structure"],
         overall_feedback: params["overall_feedback"],
         ai_essay: params["ai_essay"]
       }}
    end
  end

  def parse_speaking_question(json) do
    content = get_content!(json)

    with {:ok, params} <- parse_json_text(content) do
      questions = params["follow_ups"]

      {:ok,
       Enum.map(questions, fn question ->
         %SpeakingQuestion{question: question}
       end)}
    end
  end

  def parse_speaking_mark(json) do
    content = get_content!(json)

    with {:ok, params} <- parse_json_text(content) do
      {:ok, params}
    end
  end

  defp get_content!(json) do
    json
    |> Map.get("choices")
    |> List.first()
    |> Map.get("message")
    |> Map.get("content")
    |> String.trim()
  end

  defp parse_json_text(raw_text) do
    cleaned = format_raw_text(raw_text)

    case Jason.decode(cleaned) do
      {:ok, json} -> {:ok, json}
      {:error, error} -> {:error, {:invalid_json, "JSON decode error: #{inspect(error)}"}}
    end
  end

  defp format_raw_text(raw_text) do
    raw_text
    |> String.trim()
    |> String.replace(~r/^```json\s*/, "")
    |> String.replace(~r/```$/, "")
    |> String.trim()
  end
end

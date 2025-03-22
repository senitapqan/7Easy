defmodule App.GeminiApi.GeminiParser do
  alias App.Schemas.Writing
  alias App.Schemas.WritingResult

  def parse_essay_task(json) do
    text =
      json
      |> Map.get("candidates")
      |> List.first()
      |> Map.get("content")
      |> Map.get("parts")
      |> List.first()
      |> Map.get("text")

    %Writing{
      task: text
    }
  end

  def parse_essay_mark(json) do
    text =
      json
      |> Map.get("candidates")
      |> List.first()
      |> Map.get("content")
      |> Map.get("parts")
      |> List.first()
      |> Map.get("text")

    dbg(text)
    params = parse_marking_text(text)

    %WritingResult{
      score: params.score,
      grammar_feedback: params.grammar_feedback,
      vocabulary_feedback: params.vocabulary_feedback,
      structure_feedback: params.structure_feedback,
      overall_feedback: params.overall_feedback,
      ai_essay: params.ai_essay
    }
  end

  defp parse_marking_text(text) do
    score = String.to_float(extract_value(text, ~r/Score: \$\$\$(.*)\$\$\$\n/))
    grammar_feedback = extract_value(text, ~r/Grammar: (.*)\n/)
    vocabulary_feedback = extract_value(text, ~r/Vocabulary: (.*)\n/)
    structure_feedback = extract_value(text, ~r/Structure: (.*)\n/)
    overall_feedback = extract_value(text, ~r/Overall Feedback: (.*)\n/)
    ai_essay = extract_value(text, ~r/\*\*\*([\s\S]*?)\n/)

    %{
      score: score,
      grammar_feedback: grammar_feedback,
      vocabulary_feedback: vocabulary_feedback,
      structure_feedback: structure_feedback,
      overall_feedback: overall_feedback,
      ai_essay: ai_essay
    }
  end

  defp extract_value(response, regex) do
    case Regex.run(regex, response) do
      nil -> nil
      [_, value] -> String.trim(value)
    end
  end
end

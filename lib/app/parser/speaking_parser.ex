defmodule App.Parser.SpeakingParser do
  def parse_speaking_test(speaking, opts \\ []) do
    {part_3, opts} = Keyword.pop(opts, :part_3, true)
    [] = opts

    %{
      id: speaking.id,
      status: speaking.status,
      questions: parse_speaking_questions(speaking.speaking_questions, part_3)
    }
  end

  def parse_questions(questions) do
    %{
      questions: Enum.map(questions, &parse_speaking_question/1)
    }
  end

  def parse_speaking_history(speaking_history) do
    %{
      speaking_id: speaking_history.speaking_id,
      speaking_result_id: speaking_history.id,
      score: speaking_history.score,
      strengths: speaking_history.strengths,
      areas_for_improvement: speaking_history.areas_for_improvement,
      recommendations: speaking_history.recommendations,
      passed_time: speaking_history.updated_at,
      test: parse_speaking_content(speaking_history.content)
    }
  end

  defp parse_speaking_content(content) do
    Enum.map(content, fn item ->
      %{
        question_id: item["question_id"],
        question: item["question"],
        sub_questions: item["sub_questions"],
        user_answer_as_audio: item["file_url"],
        user_answer_as_text: item["transcript"]
      }
    end)
  end

  defp parse_speaking_questions([], _part_3), do: []

  defp parse_speaking_questions([question | questions], part_3) do
    cond do
      !part_3 and question.part == 3 ->
        parse_speaking_questions(questions, part_3)

      true ->
        [parse_speaking_question(question) | parse_speaking_questions(questions, part_3)]
    end
  end

  defp parse_speaking_question(question) do
    %{
      id: question.id,
      question: question.question,
      part: question.part,
      test_type: question.test_type,
      sub_questions: question.sub_questions
    }
  end
end

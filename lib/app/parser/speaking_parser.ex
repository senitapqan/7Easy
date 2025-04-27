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

  def parse_question(question) do
    %{
      id: question.id,
      question: question.question,
      sub_questions: question.sub_question,
      part: question.part,
      test_type: question.test_type
    }
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
      sub_questions: question.sub_question
    }
  end
end

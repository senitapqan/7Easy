defmodule App.Parser.ListeningParser do
  def parse_test(listening) do
    params = parse_test_parts(listening.titles, listening.audio_urls, listening.questions, 1)

    %{
      listening_id: listening.id,
      question_count: listening.question_count,
      test: params
    }
  end

  defp parse_test_parts([], [], _questions, _part), do: []

  defp parse_test_parts([title | titles], [audio_url | audio_urls], questions, part) do
    part_questions = Enum.filter(questions, fn question -> question.part == part end)

    [
      %{
        title: title,
        audio_url: audio_url,
        questions: parse_questions(part_questions)
      }
      | parse_test_parts(titles, audio_urls, questions, part + 1)
    ]
  end

  def parse_questions(questions) do
    Enum.map(questions, fn question ->
      %{
        question: question.question,
        answers: question.answers,
        correct_answer: question.correct_answer,
        part: question.part,
        question_id: question.id
      }
    end)
  end
end

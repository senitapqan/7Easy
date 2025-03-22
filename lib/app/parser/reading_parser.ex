defmodule App.Parser.ReadingParser do
  def parse_test(reading) do
    params = parse_test_parts(reading.titles, reading.texts, reading.questions, 1)

    %{
      reading_id: reading.id,
      question_count: reading.question_count,
      test: params
    }
  end

  def parse_test_parts([], [], _questions, _part), do: []

  def parse_test_parts([title | titles], [text | texts], questions, part) do
    part_questions = Enum.filter(questions, fn question -> question.part == part end)

    [
      %{
        title: title,
        text: text,
        questions: parse_questions(part_questions)
      }
      | parse_test_parts(titles, texts, questions, part + 1)
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

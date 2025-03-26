defmodule App.Parser.ReadingParser do
  alias App.Schemas.ReadingResult

  require Ecto.Query

  def parse_test(reading) do
    params = parse_test_parts(reading.titles, reading.texts, reading.questions, 1)

    {:ok,
     %{
       reading_id: reading.id,
       question_count: reading.question_count,
       test: params
     }}
  end

  def parse_history(reading_result) do
    reading = reading_result.reading

    {:ok,
     %{
       reading_id: reading.id,
       reading_result_id: reading_result.id,
       passed_time: reading_result.inserted_at,
       score: reading_result.score,
       correct_count: reading_result.correct_count,
       count: reading.question_count,
       test: parse_test_parts(reading.titles, reading.texts, reading_result.content, 1)
     }}
  end

  defp parse_test_parts([], [], _questions, _part), do: []

  defp parse_test_parts([title | titles], [text | texts], questions, part) do
    part_questions =
      Enum.filter(questions, fn question ->
        text_part = Map.get(question, "part") || Map.get(question, :part)
        text_part == part
      end)

    [
      %{
        title: title,
        text: text,
        part: part,
        questions: parse_questions(part_questions)
      }
      | parse_test_parts(titles, texts, questions, part + 1)
    ]
  end

  def parse_tests(tests, user_id) do
    tests =
      Enum.map(tests, fn test ->
        results =
          App.Repo.all(
            Ecto.Query.from(r in ReadingResult,
              where: r.user_id == ^user_id,
              where: r.reading_id == ^test.id
            )
          )

        results = Enum.map(results, fn result ->
          %{
            score: result.score,
            passed_time: result.inserted_at
          }
        end)

        {passed, score, passed_time} =
          case results do
            [] -> {false, nil, nil}
            results -> {true, Enum.max_by(results, & &1.score).score, Enum.max_by(results, & &1.passed_time).passed_time}
          end

        %{
          reading_id: test.id,
          passed: passed,
          score: score,
          passed_time: passed_time
        }
      end)

    {:ok, tests}
  end

  defp parse_questions([%App.Schemas.Question{} | _] = questions) do
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

  defp parse_questions(questions) do
    Enum.map(questions, fn question ->
      %{
        question: question["question"],
        answers: question["answers"],
        correct_answer: question["correct_answer"],
        part: question["part"],
        question_id: question["question_id"],
        chosen_answer: question["chosen_answer"],
        is_correct: question["is_correct"]
      }
    end)
  end
end

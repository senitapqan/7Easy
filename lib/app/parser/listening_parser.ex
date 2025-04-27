defmodule App.Parser.ListeningParser do
  alias App.Schemas.ListeningResult

  require Ecto.Query

  def parse_test(listening) do
    params = parse_test_parts(listening.titles, listening.audio_urls, listening.questions, 1)

    {:ok,
     %{
       listening_id: listening.id,
       question_count: listening.question_count,
       test: params
     }}
  end

  def parse_history(listening_result) do
    listening = listening_result.listening

    {:ok,
     %{
       listening_id: listening.id,
       listening_result_id: listening_result.id,
       passed_time: listening_result.inserted_at,
       score: listening_result.score,
       correct_count: listening_result.correct_count,
       count: listening.question_count,
       test: parse_test_parts(listening.titles, listening.audio_urls, listening_result.content, 1)
     }}
  end

  defp parse_test_parts([], [], _questions, _part), do: []

  defp parse_test_parts([title | titles], [audio_url | audio_urls], questions, part) do
    part_questions =
      Enum.filter(questions, fn question ->
        text_part = Map.get(question, "part") || Map.get(question, :part)
        text_part == part
      end)

    [
      %{
        title: title,
        audio_url: audio_url,
        part: part,
        questions: parse_questions(part_questions)
      }
      | parse_test_parts(titles, audio_urls, questions, part + 1)
    ]
  end

  def parse_tests(tests, user_id) do
    tests =
      Enum.map(tests, fn test ->
        results =
          App.Repo.all(
            Ecto.Query.from(r in ListeningResult,
              where: r.user_id == ^user_id,
              where: r.listening_id == ^test.id
            )
          )

        results =
          Enum.map(results, fn result ->
            %{
              score: result.score,
              passed_time: result.inserted_at
            }
          end)

        {passed, score, passed_time} =
          case results do
            [] ->
              {false, nil, nil}

            results ->
              {true, Enum.max_by(results, & &1.score).score, Enum.max_by(results, & &1.passed_time).passed_time}
          end

        %{
          listening_id: test.id,
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

defmodule App.Parser.WritingParser do
  alias App.Schemas.WritingResult

  require Ecto.Query

  def parse_test(writing) do
    {:ok,
     %{
       test_id: writing.id,
       task: writing.task
     }}
  end

  def parse_history(writing_history) do
    writing = writing_history.writing

    {:ok,
     %{
       test_id: writing.id,
       task: writing.task,
       essay: writing_history.user_essay,
       score: writing_history.score,
       passed_time: writing_history.inserted_at,
       ai_feedback: %{
         grammar_feedback: writing_history.grammar_feedback,
         vocabulary_feedback: writing_history.vocabulary_feedback,
         structure_feedback: writing_history.structure_feedback,
         overall_feedback: writing_history.overall_feedback,
         ai_essay: writing_history.ai_essay
       }
     }}
  end

  def parse_result(writing_result) do
    {:ok,
     %{
       score: writing_result.score,
       grammar_feedback: writing_result.grammar_feedback,
       vocabulary_feedback: writing_result.vocabulary_feedback,
       structure_feedback: writing_result.structure_feedback,
       overall_feedback: writing_result.overall_feedback,
       ai_essay: writing_result.ai_essay,
       user_essay: writing_result.user_essay,
       user_id: writing_result.user_id,
       writing_id: writing_result.writing_id
     }}
  end

  def parse_tests(tests, user_id) do
    tests =
      Enum.map(tests, fn test ->
        results =
          App.Repo.all(
            Ecto.Query.from(r in WritingResult,
              where: r.user_id == ^user_id,
              where: r.writing_id == ^test.id
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
          writing_id: test.id,
          passed: passed,
          score: score,
          passed_time: passed_time
        }
      end)

    {:ok, tests}
  end
end

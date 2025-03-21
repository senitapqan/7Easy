defmodule App.Parser.WritingParser do
  def parse_test(writing) do
    %{
      task: writing.task
    }
  end

  def parse_result(writing_result) do
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
    }
  end
end

defmodule App.Parser.ProfileParser do
  alias App.Schemas.User

  def parse_profile(%User{} = user) do
    %{
      user_id: user.id,
      email: user.email,
      avg_listening_score: round_score(user.avg_listening_score || 0.0),
      avg_reading_score: round_score(user.avg_reading_score || 0.0),
      avg_writing_score: round_score(user.avg_writing_score || 0.0),
      avg_speaking_score: round_score(user.avg_speaking_score || 0.0),
      results:
        parse_listening_results(user.listening_results) ++
          parse_reading_results(user.reading_results) ++
          parse_writing_results(user.writing_results)
    }
  end

  defp round_score(score) do
    base = Float.floor(score)
    decimal = score - base

    cond do
      decimal < 0.25 -> base * 1.0
      decimal < 0.75 -> base + 0.5
      true -> base + 1.0
    end
  end

  defp parse_listening_results(results) do
    Enum.map(results, fn result ->
      %{
        test_id: result.listening_id,
        test_type: "listening",
        correct_count: result.correct_count,
        score: result.score,
        taken_at: result.inserted_at
      }
    end)
  end

  defp parse_reading_results(results) do
    Enum.map(results, fn result ->
      %{
        test_id: result.reading_id,
        test_type: "reading",
        correct_count: result.correct_count,
        score: result.score,
        taken_at: result.inserted_at
      }
    end)
  end

  defp parse_writing_results(results) do
    Enum.map(results, fn result ->
      %{
        test_id: result.writing_id,
        test_type: "writing",
        score: result.score,
        taken_at: result.inserted_at
      }
    end)
  end
end

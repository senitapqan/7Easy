defmodule App.Parser.ProfileParser do
  alias App.Schemas.User

  def parse_profile(%User{} = user) do
    %{
      user_id: user.id,
      email: user.email,
      current_score: user.current_score,
      listening_results: parse_listening_results(user.listening_results),
      reading_results: parse_reading_results(user.reading_results),
      writing_results: parse_writing_results(user.writing_results)
    }
  end

  defp parse_listening_results(results) do
    results
    |> Enum.map(fn result ->
      %{
        test_id: result.test_id,
        correct_count: result.correct_count,
        incorrect_count: result.incorrect_count,
        score: result.score,
      }
    end)
  end

  defp parse_reading_results(results) do
    results
    |> Enum.map(fn result ->
      %{
        test_id: result.test_id,
        correct_count: result.correct_count,
        incorrect_count: result.incorrect_count,
        score: result.score,
      }
    end)
  end

  defp parse_writing_results(results) do
    results
    |> Enum.map(fn result ->
      %{
        test_id: result.test_id,
        score: result.score,
      }
    end)
  end
end

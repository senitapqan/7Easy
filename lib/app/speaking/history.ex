defmodule App.Speaking.History do
  alias App.Parser.SpeakingParser
  alias App.SpeakingContext

  def history(user_id, result_id) do
    speaking_result = SpeakingContext.get_speaking_result(result_id, preload: [:speaking])

    cond do
      speaking_result == nil -> {:error, :result_not_found}
      speaking_result.speaking.status != "completed" -> {:error, :speaking_not_completed}
      speaking_result.user_id != user_id -> {:error, :user_didnt_pass_test}
      true -> {:ok, SpeakingParser.parse_speaking_history(speaking_result)}
    end
  end
end

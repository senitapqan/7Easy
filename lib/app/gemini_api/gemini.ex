defmodule App.GeminiApi.Gemini do
  alias App.Schemas.Writing
  alias App.Schemas.WritingResult

  defp impl do
    Application.get_env(
      :app,
      :gemini_client,
      App.GeminiApi.GeminiClient
    )
  end

  @callback generate_essay() :: {:ok, %Writing{}} | {:error, atom()}
  @callback mark_essay(essay :: String.t(), question :: String.t()) :: {:ok, %WritingResult{}} | {:error, atom()}

  def generate_essay() do
    impl().generate_essay()
  end

  def mark_essay(essay, question) do
    impl().mark_essay(essay, question)
  end
end

defmodule App.OpenAi.Gpt do
  alias App.Schemas.SpeakingQuestion
  alias App.Schemas.Writing
  alias App.Schemas.WritingResult

  defp impl do
    Application.get_env(
      :seven_easy,
      :gpt_client,
      App.OpenAi.GptClient
    )
  end

  @callback generate_speaking_question(content :: map()) ::
              {:ok, [%SpeakingQuestion{}]} | {:error, atom()} | {:error, {atom(), String.t()}}
  @callback generate_essay() :: {:ok, %Writing{}} | {:error, {atom(), String.t()}} | {:error, atom()}
  @callback mark_essay(essay :: String.t(), question :: String.t()) ::
              {:ok, %WritingResult{}} | {:error, atom()} | {:error, {atom(), String.t()}}
  @callback mark_speaking_test(content :: map()) :: {:ok, map()} | {:error, atom()} | {:error, {atom(), String.t()}}

  def generate_essay() do
    impl().generate_essay()
  end

  def mark_essay(essay, question) do
    impl().mark_essay(essay, question)
  end

  def generate_speaking_question(content) do
    impl().generate_speaking_question(content)
  end

  def mark_speaking_test(content) do
    impl().mark_speaking_test(content)
  end
end

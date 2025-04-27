defmodule App.StubGpt do
  @behaviour App.OpenAi.Gpt

  alias App.Schemas.SpeakingQuestion
  alias App.Schemas.Writing
  alias App.Schemas.WritingResult

  @impl true
  def generate_essay() do
    {:ok, %Writing{}}
  end

  @impl true
  def mark_essay(_essay, _question) do
    {:ok, %WritingResult{}}
  end

  @impl true
  def generate_speaking_question(_content) do
    {:ok, [%SpeakingQuestion{}, %SpeakingQuestion{}]}
  end

  @impl true
  def mark_speaking_test(_content) do
    {:ok, %{}}
  end
end

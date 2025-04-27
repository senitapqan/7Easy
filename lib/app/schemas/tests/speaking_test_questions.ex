defmodule App.Schemas.SpeakingTestQuestion do
  use App.Schema

  alias App.Schemas.Speaking
  alias App.Schemas.SpeakingQuestion

  schema "speaking_test_questions" do
    belongs_to :speaking, Speaking
    belongs_to :speaking_question, SpeakingQuestion

    timestamps()
  end
end

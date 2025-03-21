defmodule App.Schemas.WritingResult do
  use App.Schema

  alias App.Schemas.User
  alias App.Schemas.WritingTest

  schema "writing_results" do
    field :score, :float

    field :user_essay, :string
    field :ai_essay, :string

    field :grammar_feedback, :string
    field :vocabulary_feedback, :string
    field :structure_feedback, :string
    field :overall_feedback, :string

    belongs_to :user, User
    belongs_to :writing, WritingTest

    timestamps()
  end
end

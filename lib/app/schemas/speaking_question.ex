defmodule App.Schemas.SpeakingQuestion do
  use App.Schema

  alias App.Schemas.Speaking
  alias App.Schemas.SpeakingTestQuestion

  schema "speaking_questions" do
    field :question, :string
    field :sub_question, {:array, :string}
    field :part, :integer
    field :test_type, :string

    many_to_many :speaking, Speaking, join_through: SpeakingTestQuestion

    timestamps()
  end
end

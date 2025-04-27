defmodule App.Schemas.SpeakingResult do
  use App.Schema

  alias App.Schemas.Speaking
  alias App.Schemas.User

  schema "speaking_results" do
    belongs_to :user, User
    belongs_to :speaking, Speaking

    field :score, :float
    field :content, {:array, :map}
    field :comment, :string

    timestamps()
  end
end

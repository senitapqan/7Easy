defmodule App.Schemas.ListeningResult do
  use App.Schema

  alias App.Schemas.Listening
  alias App.Schemas.User

  schema "listening_results" do
    field :content, {:array, :map}

    field :correct_count, :integer
    field :score, :float

    belongs_to :user, User
    belongs_to :listening, Listening

    timestamps()
  end
end

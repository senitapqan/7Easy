defmodule App.Schemas.ReadingResult do
  use App.Schema

  alias App.Schemas.Reading
  alias App.Schemas.User

  schema "reading_results" do
    field :content, {:array, :map}
    field :correct_count, :integer
    field :score, :float

    belongs_to :user, User
    belongs_to :reading, Reading

    timestamps()
  end
end

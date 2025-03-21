defmodule App.Schemas.User do
  use Ecto.Schema

  alias App.Schemas.ListeningResult
  alias App.Schemas.ReadingResult
  alias App.Schemas.WritingResult

  schema "users" do
    field :email, :string
    field :password, :string
    field :current_score, :float

    has_many :listening_results, ListeningResult
    has_many :reading_results, ReadingResult
    has_many :writing_results, WritingResult

    timestamps()
  end
end

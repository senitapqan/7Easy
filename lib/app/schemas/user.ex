defmodule App.Schemas.User do
  use Ecto.Schema

  alias App.Schemas.ListeningResult
  alias App.Schemas.ReadingResult
  alias App.Schemas.SpeakingResult
  alias App.Schemas.WritingResult

  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, :string

    field :avg_listening_score, :float
    field :avg_reading_score, :float
    field :avg_writing_score, :float
    field :avg_speaking_score, :float

    has_many :listening_results, ListeningResult
    has_many :reading_results, ReadingResult
    has_many :writing_results, WritingResult
    has_many :speaking_results, SpeakingResult

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:id, :email, :password, :updated_at, :inserted_at])
    |> validate_required([:email, :password])
    |> unique_constraint(:email, name: :unique_user_email)
  end
end

defmodule App.Schema.User do
  use App.Schema

  alias App.Schema.Results.ListeningResult
  alias App.Schema.Results.ReadingResult
  alias App.Schema.Results.WritingResult

  @status [:active, :deleted]

  schema "users" do
    field :user_id, Ecto.UUID, autogenerate: true
    field :name, :string
    field :surname, :string
    field :phone, :string
    field :username, :string
    field :email, :string
    field :password, :string
    field :current_result, :integer
    field :status, Ecto.Enum, values: @status, default: :active

    has_many :listening_results, ListeningResult
    has_many :reading_results, ReadingResult
    has_many :writing_results, WritingResult
    timestamps()
  end
end

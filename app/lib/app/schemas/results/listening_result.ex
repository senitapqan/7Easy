defmodule App.Schema.Results.ListeningResult do
  use App.Schema

  alias App.Schema.Test
  alias App.Schema.User

  @status [:active, :deleted]

  schema "listening_results" do
    field :content, :map
    field :correct_count, :integer
    field :incorrect_count, :integer
    field :result, :integer
    field :status, Ecto.Enum, values: @status, default: :active

    belongs_to :user, User
    belongs_to :test, Test
    timestamps()
  end
end

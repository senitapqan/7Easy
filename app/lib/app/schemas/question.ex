defmodule App.Schema.Question do
  use App.Schema

  alias App.Schema.Test
  @status [:active, :deleted]

  schema "questions" do
    field :question, :string
    field :answers, {:array, :string}
    field :correct_answer, :string
    field :status, Ecto.Enum, values: @status, default: :active

    belongs_to :test, Test
    timestamps()
  end
end

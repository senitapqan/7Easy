defmodule App.Schemas.Question do
  use App.Schema

  schema "questions" do
    field :question, :string

    field :answers, {:array, :string}
    field :correct_answer, :string

    field :part, :integer

    field :test_type, :string
    field :test_id, :integer

    timestamps()
  end
end

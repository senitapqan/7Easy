defmodule App.Schemas.Reading do
  use App.Schema

  alias App.Schemas.Question

  schema "reading_tests" do
    field :titles, {:array, :string}
    field :texts, {:array, :string}
    field :question_count, :integer

    has_many :questions, Question, foreign_key: :test_id

    timestamps()
  end
end

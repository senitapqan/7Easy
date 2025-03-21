defmodule App.Schemas.Listening do
  use App.Schema

  alias App.Schemas.Question

  schema "listening_tests" do
    field :titles, {:array, :string}
    field :audio_urls, {:array, :string}
    field :question_count, :integer

    has_many :questions, Question, foreign_key: :test_id

    timestamps()
  end
end

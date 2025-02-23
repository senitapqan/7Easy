defmodule App.Schema.Examination.Test do
  use App.Schema

  alias App.Schema.Question

  @test_type [:listening, :reading]

  @status [:active, :deleted]

  schema "tests" do
    field :test_type, Ecto.Enum, values: @test_type
    field :audio_link, :string
    field :text, :string
    field :question_count, :integer
    field :status, Ecto.Enum, values: @status, default: :active

    has_many :questions, Question
    timestamps()
  end
end

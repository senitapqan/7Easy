defmodule App.Schemas.Speaking do
  use App.Schema

  alias App.Schemas.SpeakingQuestion
  alias App.Schemas.SpeakingResult
  alias App.Schemas.SpeakingTestQuestion
  alias App.Schemas.User

  schema "speaking_tests" do
    field :status, :string
    field :question_count, :integer
    belongs_to :user, User

    has_many :speaking_results, SpeakingResult
    many_to_many :speaking_questions, SpeakingQuestion, join_through: SpeakingTestQuestion

    timestamps()
  end
end

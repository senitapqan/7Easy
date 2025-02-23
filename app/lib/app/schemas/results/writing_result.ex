defmodule App.Schema.Results.WritingResult do
  use App.Schema

  alias App.Schema.User
  alias App.Schema.WritingTopic

  @status [:active, :deleted]

  schema "writing_results" do
    field :result, :integer
    field :content, :string
    field :status, Ecto.Enum, values: @status, default: :active

    belongs_to :user, User
    belongs_to :writing_topic, WritingTopic
    timestamps()
  end
end

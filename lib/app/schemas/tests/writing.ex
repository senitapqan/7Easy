defmodule App.Schemas.Writing do
  use App.Schema

  schema "writing_tests" do
    field :task, :string

    timestamps()
  end
end

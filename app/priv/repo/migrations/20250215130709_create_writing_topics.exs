defmodule App.Repo.Migrations.CreateWritingTopics do
  use Ecto.Migration

  def change do
    create table(:writing_topics) do
      add :topic, :string, null: false
      add :status, :string, null: false

      timestamps()
    end
  end
end

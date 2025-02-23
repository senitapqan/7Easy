defmodule App.Repo.Migrations.WritingResults do
  use Ecto.Migration

  def change do
    create table(:writing_results) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :writing_topic_id, references(:writing_topics, on_delete: :delete_all), null: false
      add :result, :integer
      add :content, :string
      add :status, :string, null: false

      timestamps()
    end
  end
end

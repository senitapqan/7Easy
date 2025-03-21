defmodule App.Repo.Migrations.CreateWritingResults do
  use Ecto.Migration

  def change do
    create table(:writing_results) do
      add :score, :float
      add :user_essay, :text
      add :ai_essay, :text
      add :grammar_feedback, :text
      add :vocabulary_feedback, :text
      add :structure_feedback, :text
      add :overall_feedback, :text

      add :writing_id, references(:writing_tests, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end

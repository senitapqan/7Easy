defmodule App.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :question, :text, null: false
      add :answers, {:array, :text}, null: false
      add :correct_answer, :text, null: false

      add :part, :integer, null: false
      add :test_type, :string, null: false
      add :test_id, :integer, null: false

      timestamps()
    end
  end
end

defmodule App.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :test_id, references(:tests, on_delete: :delete_all), null: false
      add :question, :string, null: false
      add :answers, {:array, :string}, null: false
      add :correct_answer, :string, null: false
      add :status, :string, null: false

      timestamps()
    end
  end
end

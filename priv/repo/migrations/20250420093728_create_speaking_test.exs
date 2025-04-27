defmodule App.Repo.Migrations.CreateSpeakingTest do
  use Ecto.Migration

  def change do
    create table(:speaking_tests) do
      add :status, :string
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end

    create table(:speaking_test_questions) do
      add :speaking_id, references(:speaking_tests, on_delete: :delete_all)
      add :speaking_question_id, references(:speaking_questions, on_delete: :delete_all)

      timestamps()
    end

    create index(:speaking_test_questions, [:speaking_id])
    create index(:speaking_test_questions, [:speaking_question_id])
  end
end

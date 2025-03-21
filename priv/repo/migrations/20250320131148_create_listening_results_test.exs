defmodule App.Repo.Migrations.CreateListeningResultsTest do
  use Ecto.Migration

  def change do
    create table(:listening_results) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :listening_id, references(:listening_tests, on_delete: :delete_all), null: false

      add :content, {:array, :map}, null: false
      add :correct_count, :integer
      add :score, :float

      timestamps()
    end
  end
end

defmodule App.Repo.Migrations.CreateReadingResultsTest do
  use Ecto.Migration

  def change do
    create table(:reading_results) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :reading_id, references(:reading_tests, on_delete: :delete_all), null: false
      add :content, {:array, :map}, null: false
      add :correct_count, :integer
      add :score, :float

      timestamps()
    end
  end
end

defmodule App.Repo.Migrations.ReadingResults do
  use Ecto.Migration

  def change do
    create table(:reading_results) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :test_id, references(:tests, on_delete: :delete_all), null: false
      add :content, :map, null: false
      add :correct_count, :integer
      add :incorrect_count, :integer
      add :result, :integer
      add :status, :string, null: false

      timestamps()
    end
  end
end

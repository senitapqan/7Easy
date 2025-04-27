defmodule App.Repo.Migrations.CreateSpeakingResults do
  use Ecto.Migration

  def change do
    create table(:speaking_results) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :speaking_id, references(:speaking_tests, on_delete: :delete_all), null: false

      add :score, :float
      add :content, {:array, :map}
      add :comment, :text

      timestamps()
    end
  end
end

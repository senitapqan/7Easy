defmodule App.Repo.Migrations.CreateReadingTest do
  use Ecto.Migration

  def change do
    create table(:reading_tests) do
      add :titles, {:array, :string}
      add :texts, {:array, :text}
      add :question_count, :integer

      timestamps()
    end
  end
end

defmodule App.Repo.Migrations.CreateWritingTest do
  use Ecto.Migration

  def change do
    create table(:writing_tests) do
      add :task, :text

      timestamps()
    end
  end
end

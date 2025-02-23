defmodule App.Repo.Migrations.CreateTest do
  use Ecto.Migration

  def change do
    create table(:tests) do
      add :test_type, :string, null: false
      add :audio_link, :string
      add :text, :string
      add :question_count, :integer
      add :status, :string, null: false
      timestamps()
    end
  end
end

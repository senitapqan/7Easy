defmodule App.Repo.Migrations.CreateListeningTest do
  use Ecto.Migration

  def change do
    create table(:listening_tests) do
      add :titles, {:array, :string}
      add :audio_urls, {:array, :string}
      add :question_count, :integer

      timestamps()
    end
  end
end

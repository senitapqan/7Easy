defmodule App.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password, :string, null: false

      add :avg_listening_score, :float
      add :avg_reading_score, :float
      add :avg_writing_score, :float
      add :avg_speaking_score, :float

      timestamps()
    end

    create unique_index(:users, [:email], name: :unique_user_email)
  end
end

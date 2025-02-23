defmodule App.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :user_id, :uuid, null: false
      add :username, :string, null: false
      add :name, :string, null: false
      add :surname, :string, null: false
      add :phone, :string, null: false
      add :email, :string, null: false
      add :password, :string, null: false
      add :current_result, :integer
      add :status, :string, null: false

      timestamps()
    end
  end
end

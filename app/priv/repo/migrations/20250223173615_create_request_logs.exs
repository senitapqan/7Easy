defmodule App.Repo.Migrations.CreateRequestLogs do
  use Ecto.Migration

  def change do
    create table(:request_logs) do
      add :event, :string
      add :params, :map
    end
  end
end

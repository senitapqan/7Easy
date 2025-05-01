defmodule App.Repo.Migrations.CreateSpeakingQuestions do
  use Ecto.Migration

  def change do
    create table(:speaking_questions) do
      add :question, :text
      add :sub_questions, {:array, :text}
      add :part, :integer
      add :test_type, :string

      timestamps()
    end
  end
end

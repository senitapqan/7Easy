defmodule App.Results do
  alias App.Repo
  alias App.Schemas.ListeningResult
  alias App.Schemas.ReadingResult

  import Ecto.Changeset

  def create_listening_result(attrs) do
    %ListeningResult{}
    |> change(attrs)
    |> Repo.insert()
  end

  def create_reading_result(attrs) do
    %ReadingResult{}
    |> change(attrs)
    |> Repo.insert()
  end
end

defmodule App.Users do
  import Ecto.Changeset

  alias App.Parser.ProfileParser
  alias App.Repo
  alias App.Schemas.User

  def create_user(attrs) do
    %User{}
    |> change(attrs)
    |> App.Repo.insert()
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def get_profile(user_id) do
     User
    |> Repo.get(user_id)
    |> Repo.preload([:listening_results, :reading_results, :writing_results])
    |> ProfileParser.parse_profile()
  end
end

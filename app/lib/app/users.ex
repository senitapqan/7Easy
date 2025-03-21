defmodule App.Users do
  import Ecto.Changeset

  alias App.Schemas.User
  alias App.Repo

  def create_user(attrs) do
    %User{}
    |> change(attrs)
    |> App.Repo.insert()
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end
end

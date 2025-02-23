defmodule App.Users do
  import Ecto.Changeset

  alias App.Schema.User

  def create_user(attrs) do
    %User{}
    |> change(attrs)
    |> App.Repo.insert()
  end

  def get_user_by_phone(phone, opts \\ []) do
    preload = Keyword.get(opts, :preload, [])
    [] = opts

    User
    |> App.Repo.get_by(phone: phone)
    |> App.Repo.preload(preload)
  end

  def get_user_by_email(email, opts \\ []) do
    preload = Keyword.get(opts, :preload, [])
    [] = opts

    User
    |> App.Repo.get_by(email: email)
    |> App.Repo.preload(preload)
  end

  def get_user_by_id(id, opts \\ []) do
    preload = Keyword.get(opts, :preload, [])
    [] = opts

    User
    |> App.Repo.get(id)
    |> App.Repo.preload(preload)
  end
end

defmodule App.Profiles do
  alias App.Parser.ProfileParser
  alias App.Auth.Schemas.User
  alias App.Repo

  def get_profile(user_id) do
    User
    |> Repo.get(user_id)
    |> Repo.preload([:listening_results, :reading_results, :writing_results])
    |> ProfileParser.parse_profile()
  end
end

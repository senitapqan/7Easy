defmodule App.Users do
  import Ecto.Changeset

  alias App.Parser.ProfileParser
  alias App.Repo
  alias App.Schemas.User

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> App.Repo.insert()
  end

  def get_user(user_id, opts \\ []) do
    preload = Keyword.get(opts, :preload, [])

    Repo.get!(User, user_id)
    |> Repo.preload(preload)
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

  def update_avg_score(user_id, :writing, score) do
    user = get_user(user_id, preload: :writing_results)
    results = user.writing_results
    results_count = length(results)

    avg_score = user.avg_writing_score || 0
    new_avg_score = (avg_score * results_count + score) / (results_count + 1)

    user
    |> change(%{avg_writing_score: new_avg_score})
    |> Repo.update!()
  end

  def update_avg_score(user_id, :reading, score) do
    user = get_user(user_id, preload: :reading_results)
    results = user.reading_results
    results_count = length(results)

    avg_score = user.avg_reading_score || 0
    new_avg_score = (avg_score * results_count + score) / (results_count + 1)

    user
    |> change(%{avg_reading_score: new_avg_score})
    |> Repo.update!()
  end

  def update_avg_score(user_id, :listening, score) do
    user = get_user(user_id, preload: :listening_results)
    results = user.listening_results
    results_count = length(results)

    avg_score = user.avg_listening_score || 0
    new_avg_score = (avg_score * results_count + score) / (results_count + 1)

    user
    |> change(%{avg_listening_score: new_avg_score})
    |> Repo.update!()
  end
end

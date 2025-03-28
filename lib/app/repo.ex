defmodule App.Repo do
  use Ecto.Repo,
    otp_app: :seven_easy,
    adapter: Ecto.Adapters.Postgres
end

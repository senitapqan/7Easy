{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start(timeout: :infinity)
Ecto.Adapters.SQL.Sandbox.mode(App.Repo, :manual)

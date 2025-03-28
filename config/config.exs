# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :seven_easy,
  ecto_repos: [App.Repo],
  generators: [timestamp_type: :utc_datetime]

config :seven_easy, App.Repo, migration_timestamps: [type: :utc_datetime_usec]

config :geminex,
  environment: :sandbox,
  api_key: System.get_env("GEMINI_API_KEY"),
  api_secret: System.get_env("GEMINI_API_SECRET")

# Configures the endpoint
config :seven_easy, SevenEasyWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: AppWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: App.PubSub,
  live_view: [signing_salt: "KVEqOQN/"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :seven_easy, env: config_env()

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

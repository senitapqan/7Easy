defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticate do
    plug AppWeb.Plugs.Authenticate
  end

  scope "/auth" do
    pipe_through [:api]

    post "/sign_in", AuthController, :sign_in
    post "/sign_up", AuthController, :sign_up
  end

  scope "/api", AppWeb do
    pipe_through [:api, :authenticate]
  end

  if Application.compile_env(:app, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: AppWeb.Telemetry
    end
  end
end

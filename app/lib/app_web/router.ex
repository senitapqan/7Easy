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

    post "/sign_in", AppWeb.AuthController, :sign_in
    post "/sign_up", AppWeb.AuthController, :sign_up
  end

  scope "/api" do
    pipe_through [:api, :authenticate]

    get "/test", AppWeb.TestController, :get_test
    post "/test/save", AppWeb.TestController, :save_test
    post "/test/writing", AppWeb.TestController, :save_writing_test
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

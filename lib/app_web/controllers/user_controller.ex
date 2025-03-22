defmodule AppWeb.UserController do
  use AppWeb, :controller

  def get_profile(conn, _params) do
    user_id = conn.assigns.user_id
    json(conn, App.Users.get_profile(user_id))
  end
end

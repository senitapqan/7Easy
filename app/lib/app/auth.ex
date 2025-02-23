defmodule App.Auth do
  use Joken.Config

  alias App.Users
  alias App.Schema.User

  @salt System.get_env("SALT")

  def sign_in(%{email: email, password: password}, token) when is_binary(token) do
    user = App.Users.get_user_by_email(email)

    validate_user_and_token(user, Bcrypt.verify_pass(password, user.password))
  end

  def sign_up(attrs) do
    attrs = Map.put(attrs, :password, Bcrypt.hash_pwd_salt(attrs.password))

    case Users.create_user(attrs) do
      {:ok, user} ->
        {:ok, generate_token!(user)}

      {:error, error} ->
        {:error, error}
    end
  end

  defp validate_user_and_token(nil, _), do: {:error, :invalid_credentials}
  defp validate_user_and_token(_user, false), do: {:error, :invalid_credentials}
  defp validate_user_and_token(user, true), do: verify_token(token)

  defp generate_token!(%User{user_id: user_id} = user) do
    {:ok, token, _claims} = generate_and_sign!(%{user_id: user_id})
    {:ok, token}
  end

  defp verify_token(token) do
    {:ok, token, claims} = verify_and_validate(token)
    {:ok, claims}
  end
end

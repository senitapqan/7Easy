defmodule App.Auth do
  use Joken.Config

  alias App.Users
  alias App.Schema.User

  @signer System.get_env("JWT_PRIVATE_KEY")

  def sign_in(%{email: email, password: password}) do
    user = App.Users.get_user_by_email(email)
    validate_user_and_token(user, Bcrypt.verify_pass(password, user.password))
  end

  def sign_up(attrs) do
    attrs = Map.put(attrs, :password, Bcrypt.hash_pwd_salt(attrs.password))

    case Users.create_user(attrs) do
      {:ok, user} ->
        {:ok, user.user_id}

      {:error, error} ->
        {:error, error}
    end
  end

  def verify_token(nil), do: false
  def verify_token(token) do
    case verify_and_validate(token) do
      {:ok, claims} -> {:ok, claims.user_id}
      {:error, _error} -> false
    end
  end

  defp validate_user_and_token(nil, _), do: {:error, :invalid_credentials}
  defp validate_user_and_token(_user, false), do: {:error, :invalid_credentials}
  defp validate_user_and_token(user, true), do: generate_token(user)

  defp generate_token(%User{user_id: user_id}) do
    case generate_and_sign(%{"user_id" => user_id}, @signer) do
      {:ok, token, _claims} -> {:ok, token}
      {:error, error} ->
        {:error, error}
    end
  end
end

defmodule App.Auth do
  use Joken.Config

  alias App.Schemas.User
  alias App.Users

  def sign_in(%{email: email, password: password}) do
    user = Users.get_user_by_email(email)
    validate_user(user, password)
  end

  def sign_up(attrs) do
    attrs = Map.put(attrs, :password, Bcrypt.hash_pwd_salt(attrs.password))

    case Users.create_user(attrs) do
      {:ok, user} ->
        {:ok, user.id}

      {:error, %Ecto.Changeset{errors: [email: {"has already been taken", _}]}} ->
        {:error, :email_taken}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def verify_token(nil), do: false

  def verify_token(token) do
    signer = Joken.Signer.create("HS256", secret_key())

    case verify_and_validate(token, signer) do
      {:ok, claims} -> {:ok, claims["user_id"]}
      {:error, _error} -> false
    end
  end

  defp validate_user(nil, _password), do: {:error, :invalid_credentials}
  defp validate_user(user, password), do: generate_token(user, Bcrypt.verify_pass(password, user.password))

  defp generate_token(_user, false), do: {:error, :invalid_credentials}

  defp generate_token(%User{id: user_id}, true) do
    signer = Joken.Signer.create("HS256", secret_key())

    case generate_and_sign(%{"user_id" => user_id}, signer) do
      {:ok, token, _claims} ->
        {:ok, token}

      {:error, error} ->
        {:error, error}
    end
  end

  defp secret_key do
    System.get_env("JWT_PRIVATE_KEY") || raise "JWT_PRIVATE_KEY is not set"
  end
end

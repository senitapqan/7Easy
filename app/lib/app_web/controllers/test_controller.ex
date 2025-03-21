defmodule AppWeb.TestController do
  alias App.Tests

  use AppWeb, :controller

  def get_test(conn, _params) do
    type = conn.params["type"]
    user_id = conn.assigns.user_id

    case type do
      "listening" ->
        json(conn, Tests.pull_listening_test(user_id))
      "reading" ->
        json(conn, Tests.pull_reading_test(user_id))
      "writing" ->
        json(conn, Tests.pull_writing_test())
      _ ->
        json(conn, %{error: "Invalid test type"})
    end
  end

  defmodule SaveTestContract do
    use Drops.Contract

    schema(atomize: true) do
      %{
        required(:test_type) => string(:filled?),
        required(:test_id) => string(:filled?),
        optional(:answers) =>
          list(%{
            required(:question_id) => string(:filled?),
            required(:answer) => string()
          })
      }
    end
  end

  def save_test(conn, unsafe_params) do
    user_id = conn.assigns.user_id

    with {:ok, params} <- SaveTestContract.conform(unsafe_params) do
      case params.test_type do
        "listening" ->
          Tests.save_listening_test(user_id, params.test_id, params.answers)

        "reading" ->
          Tests.save_reading_test(user_id, params.test_id, params.answers)
      end
    end

    json(conn, %{success: true})
  end

  defmodule SaveWritingTestContract do
    use Drops.Contract

    schema(atomize: true) do
      %{
        required(:test_id) => integer(),
        required(:essay) => string(:filled?)
      }
    end
  end

  def save_writing_test(conn, unsafe_params) do
    user_id = conn.assigns.user_id

    with {:ok, params} <- SaveWritingTestContract.conform(unsafe_params) do
      json(conn, Tests.save_writing_test(user_id, params.test_id, params.essay))
    else
      {:error, _} ->
        conn
        |> put_status(422)
        |> json(%{error: "Invalid params"})
    end
  end
end

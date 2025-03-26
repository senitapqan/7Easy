defmodule AppWeb.TestController do
  alias App.Tests

  use AppWeb, :controller

  def pass_test(conn, _params) do
    case get_variables(conn, %{"type" => "type", "test_id" => "test_id"}) do
      {:ok, %{"type" => type, "test_id" => test_id}} ->
        case type do
          "listening" ->
            handle_result(conn, Tests.pass_listening_test(test_id), test_id: test_id)

          "reading" ->
            handle_result(conn, Tests.pass_reading_test(test_id), test_id: test_id)

          "writing" ->
            handle_result(conn, Tests.pass_writing_test(test_id), test_id: test_id)

          _ ->
            conn
            |> put_status(422)
            |> json(%{error: "Invalid test type"})
        end

      {:error, error} ->
        conn
        |> put_status(422)
        |> json(%{error: "Invalid params", details: error})
    end
  end

  def get_tests(conn, _params) do
    case get_variables(conn, %{"type" => "type"}) do
      {:ok, %{"type" => type}} ->
        user_id = conn.assigns.user_id

        case type do
          "listening" ->
            handle_result(conn, Tests.pull_listening_tests(user_id), user_id: user_id)

          "reading" ->
            handle_result(conn, Tests.pull_reading_tests(user_id), user_id: user_id)

          "writing" ->
            handle_result(conn, Tests.pull_writing_tests(user_id), user_id: user_id)

          _ ->
            conn
            |> put_status(422)
            |> json(%{error: "Invalid test type"})
        end

      {:error, error} ->
        conn
        |> put_status(422)
        |> json(%{error: "Invalid params", details: error})
    end
  end

  def get_history(conn, _params) do
    case get_variables(conn, %{"type" => "type", "result_id" => "result_id"}) do
      {:ok, %{"type" => type, "result_id" => result_id}} ->
        user_id = conn.assigns.user_id

        case type do
          "listening" ->
            handle_result(conn, Tests.pull_listening_history(user_id, result_id), [user_id: user_id, result_id: result_id])

          "reading" ->
            handle_result(conn, Tests.pull_reading_history(user_id, result_id), [user_id: user_id, result_id: result_id])

          "writing" ->
            handle_result(conn, Tests.pull_writing_history(user_id, result_id), [user_id: user_id, result_id: result_id])

          _ ->
            conn
            |> put_status(422)
            |> json(%{error: "Invalid test type"})
        end

      {:error, error} ->
        conn
        |> put_status(422)
        |> json(%{error: "Invalid params", details: error})
    end
  end

  defmodule SaveTestContract do
    use Drops.Contract

    schema(atomize: true) do
      %{
        required(:test_type) => string(:filled?),
        required(:test_id) => integer(),
        optional(:essay) => string(:filled?),
        optional(:answers) =>
          list(%{
            required(:question_id) => integer(),
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
          handle_result(conn, Tests.save_listening_test(user_id, params.test_id, params.answers), user_id: user_id)

        "reading" ->
          handle_result(conn, Tests.save_reading_test(user_id, params.test_id, params.answers), user_id: user_id)

        "writing" ->
          handle_result(conn, Tests.save_writing_test(user_id, params.test_id, params.essay), user_id: user_id)
      end
    else
      {:error, error} ->
        conn
        |> put_status(422)
        |> json(%{error: "Invalid params", details: error})
    end
  end

  defp handle_result(conn, result, opts) do
    {user_id, opts} = Keyword.pop(opts, :user_id, nil)
    {test_id, opts} = Keyword.pop(opts, :test_id, nil)
    {result_id, opts} = Keyword.pop(opts, :result_id, nil)
    [] = opts

    case result do
      {:ok, result} ->
        json(conn, result)

      {:error, :failed_to_mark_essay} ->
        conn
        |> put_status(500)
        |> json(%{error: "Failed to mark essay"})

      {:error, :invalid_number_of_answers} ->
        conn
        |> put_status(400)
        |> json(%{error: "Count of answers is not equal to the count of questions"})

      {:error, :user_didnt_pass_test} ->
        conn
        |> put_status(400)
        |> json(%{error: "Looks like user didn't pass test. user_id: #{user_id}, test_id: #{result_id}"})

      {:error, :test_not_found} ->
        conn
        |> put_status(404)
        |> json(%{error: "Test with given id not found. id: #{test_id}"})
    end
  end

  defp get_variables(conn, variables) do
    values =
      Enum.reduce(variables, %{}, fn {key, _}, acc ->
        Map.put(acc, key, conn.params[key])
      end)

    case check_variables(values, variables) do
      {:ok, values} ->
        {:ok, values}

      {:error, error} ->
        {:error, error}
    end

  end

  defp check_variables(values, variables) do
    type = values["type"]

    dbg(variables)
    dbg(values)

    cond do
      type == "writing" && Enum.find(values, fn {k, _} -> k == "test_id" end) ->
        {:ok, values}

      Enum.any?(values, fn {_, value} -> value == nil end) ->
        {:error, "Missing some of variables: #{inspect(values)}"}

      true ->
        {:ok, values}
    end
  end
end

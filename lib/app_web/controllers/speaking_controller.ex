defmodule AppWeb.SpeakingController do
  use AppWeb, :controller

  alias App.SpeakingContext

  import Ecto.Changeset

  def start_speaking(conn, _params) do
    user_id = conn.assigns.user_id
    handle_result(conn, SpeakingContext.start_speaking(user_id))
  end

  defmodule AnswerSchema do
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field :question_id, :integer
      field :audio_file, :map
    end

    def changeset(answer, attrs) do
      answer
      |> cast(attrs, [:question_id, :audio_file])
      |> validate_required([:question_id, :audio_file])
      |> validate_audio_file()
    end

    defp validate_audio_file(changeset) do
      case get_change(changeset, :audio_file) do
        %Plug.Upload{content_type: content_type} ->
          if String.starts_with?(content_type, "audio/") do
            changeset
          else
            add_error(changeset, :audio_file, "must be an audio file")
          end

        _ ->
          add_error(changeset, :audio_file, "must be a valid audio file upload")
      end
    end
  end

  defmodule SpeakingContract do
    use Ecto.Schema

    embedded_schema do
      field :test_type, :string
      field :speaking_id, :integer
      embeds_many :answers, AnswerSchema
    end

    def validate_and_apply(attrs) do
      case changeset(attrs) do
        %{valid?: true} = changeset ->
          {:ok, apply_changes(changeset) |> deep_map()}

        %{valid?: false} ->
          {:error, :invalid_params}
      end
    end

    defp changeset(attrs) do
      %SpeakingContract{}
      |> cast(attrs, [:test_type, :speaking_id])
      |> cast_embed(:answers, with: &AnswerSchema.changeset/2)
      |> validate_required([:test_type, :speaking_id])
    end

    defp deep_map(struct) when is_struct(struct) do
      struct
      |> Map.from_struct()
      |> Enum.map(fn
        {k, %Plug.Upload{} = v} ->
          {k, v}

        {k, v} ->
          {k, deep_map(v)}
      end)
      |> Enum.into(%{})
    end

    defp deep_map(list) when is_list(list), do: Enum.map(list, &deep_map/1)
    defp deep_map(value), do: value
  end

  def continue_speaking(conn, unsafe_params) do
    user_id = conn.assigns.user_id

    case SpeakingContract.validate_and_apply(unsafe_params) do
      {:ok, params} ->
        handle_result(conn, SpeakingContext.continue_speaking(user_id, params.speaking_id, params.answers))

      {:error, :invalid_params} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid params"})
    end
  end

  def save_speaking(conn, unsafe_params) do
    user_id = conn.assigns.user_id

    case SpeakingContract.validate_and_apply(unsafe_params) do
      {:ok, params} ->
        handle_result(conn, SpeakingContext.save_speaking(user_id, params.speaking_id, params.answers))

      {:error, :invalid_params} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid params"})
    end
  end

  def history(conn, _params) do
    user_id = conn.assigns.user_id
    result_id = conn.params["result_id"]
    handle_result(conn, SpeakingContext.history(user_id, result_id))
  end

  defp handle_result(conn, result) do
    case result do
      {:ok, result} ->
        json(conn, result)

      {:error, {error, message}} ->
        case error do
          :http_error ->
            conn
            |> put_status(502)
            |> json(%{message: message})

          :invalid_json ->
            conn
            |> put_status(502)
            |> json(%{message: message})

          _ ->
            conn
            |> put_status(500)
            |> json(%{error: "Unknown error: #{inspect(error)}", message: message})
        end

      {:error, :timeout} ->
        conn
        |> put_status(504)
        |> json(%{message: "Timeout"})

      {:error, :transcription_failed} ->
        conn
        |> put_status(502)
        |> json(%{message: "Transcription failed"})

      {:error, :speaking_not_found} ->
        conn
        |> put_status(404)
        |> json(%{message: "Speaking not found"})

      {:error, :result_not_found} ->
        conn
        |> put_status(404)
        |> json(%{message: "Result not found"})

      {:error, :speaking_completed} ->
        conn
        |> put_status(404)
        |> json(%{message: "Speaking completed"})

      {:error, :speaking_not_completed} ->
        conn
        |> put_status(404)
        |> json(%{message: "Speaking not completed"})

      {:error, :speaking_not_started} ->
        conn
        |> put_status(404)
        |> json(%{message: "Speaking not started"})

      {:error, :user_didnt_pass_test} ->
        conn
        |> put_status(401)
        |> json(%{message: "User didn't pass the test"})

      {:error, :invalid_number_of_answers} ->
        conn
        |> put_status(400)
        |> json(%{message: "Number of answers is not equal to the number of questions"})
    end
  end
end

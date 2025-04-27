defmodule App.Assembly.SpeechToTextClient do
  @moduledoc false

  @behaviour App.Assembly.SpeechToText

  defp base_url(), do: "https://api.assemblyai.com"
  defp token(), do: System.get_env("ASSEMBLYAI_API_KEY")

  @impl true
  def recognize(%Plug.Upload{path: path}) do
    with {:ok, upload_url} <- upload_file(path) do
      start_transcription(upload_url)
    end
  end

  @impl true
  def get_operation_result(transcription_id) do
    url = "#{base_url()}/v2/transcript/#{transcription_id}"

    with {:ok, response} <- get(url, auth_headers()) do
      case response["status"] do
        "completed" -> {:ok, response["text"]}
        "failed" -> {:error, :transcription_failed}
        _ -> {:pending, :still_processing}
      end
    end
  end

  defp upload_file(path) do
    with {:ok, body} <- File.read(path),
         {:ok, %{"upload_url" => url}} <- post("#{base_url()}/v2/upload", body, [{"authorization", token()}]) do
      {:ok, url}
    end
  end

  defp start_transcription(upload_url) do
    params = %{"audio_url" => upload_url}

    with {:ok, body} <- post("#{base_url()}/v2/transcript", params, auth_headers()) do
      {:ok, body["id"]}
    end
  end

  defp post(url, params, headers) when is_map(params) do
    req()
    |> Req.request(method: :post, url: url, json: params, headers: headers)
    |> handle_response()
  end

  defp post url, params, headers do
    req()
    |> Req.request(method: :post, url: url, body: params, headers: headers)
    |> handle_response()
  end

  defp get(url, headers) do
    req()
    |> Req.request(method: :get, url: url, headers: headers)
    |> handle_response()
  end

  defp handle_response({:ok, %Req.Response{status: 200, body: body}}), do: {:ok, body}

  defp handle_response({:ok, %Req.Response{status: status, body: body}}),
    do: {:error, {:http_error, "HTTP error #{status}: #{inspect(body)}"}}

  defp handle_response({:error, reason}), do: {:error, {:http_error, "Request failed: #{inspect(reason)}"}}

  defp auth_headers(), do: [{"authorization", token()}, {"content-type", "application/json"}]
  defp req(), do: Req.new(receive_timeout: 120_000)
end

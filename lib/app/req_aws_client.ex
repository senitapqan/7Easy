defmodule App.ReqAwsClient do
  @moduledoc """
  Use req library to make requests to AWS

  https://hexdocs.pm/ex_aws/ExAws.Request.HttpClient.html#module-example
  """
  @behaviour ExAws.Request.HttpClient

  @impl true
  def request(method, url, body, headers, _http_opts) do
    result = Req.request(method: method, url: url, body: body, headers: headers, raw: true)

    case result do
      {:ok, response} ->
        {:ok, %{status_code: response.status, headers: unwrap_values(response.headers), body: response.body}}

      {:error, %Mint.TransportError{} = exception} ->
        {:error, %{reason: Mint.TransportError.message(exception)}}

      {:error, exception} ->
        {:error, %{reason: exception.message}}
    end
  end

  # ExAws expects header values to be a string. It fixes the issue with ExAws.S3.Download.get_file_size.
  #
  ## Examples
  #
  #   iex> unwrap_values([%{"content-length" => ["981"]}])
  #   [%{"content-length" => "981"}]
  #
  defp unwrap_values(headers) do
    headers
    |> Enum.map(fn {k, [v]} -> {k, v} end)
    |> Map.new()
  end
end

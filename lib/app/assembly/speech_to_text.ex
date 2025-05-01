defmodule App.Assembly.SpeechToText do
  defp impl do
    Application.get_env(
      :seven_easy,
      :speech_to_text_client,
      App.Assembly.SpeechToTextClient
    )
  end

  @callback recognize(%Plug.Upload{path: String.t()}) ::
              {:ok, String.t()} | {:error, atom()} | {:error, {atom(), String.t()}}
  @callback get_operation_result(integer()) :: {:ok, String.t()} | {:error, atom()} | {:error, {atom(), String.t()}}

  def recognize(audio_file) do
    impl().recognize(audio_file)
  end

  def get_operation_result(operation_id) do
    impl().get_operation_result(operation_id)
  end
end

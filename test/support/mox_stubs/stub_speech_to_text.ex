defmodule App.StubSpeechToText do
  @behaviour App.Assembly.SpeechToText

  @impl true
  def recognize(%Plug.Upload{path: _path}) do
    {:ok, "123"}
  end

  @impl true
  def get_operation_result(_operation_id) do
    {:ok, "Hello, world!"}
  end
end

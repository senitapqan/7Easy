defmodule App.Assembly.SpeechToTextTest do
  use AppWeb.ConnCase

  describe "Works with real API" do
    @describetag :live_network
    setup do
      old_env = Application.get_env(:seven_easy, :speech_to_text_client)
      Application.put_env(:seven_easy, :speech_to_text_client, App.Assembly.SpeechToTextClient)

      on_exit(fn ->
        Application.put_env(:seven_easy, :speech_to_text_client, old_env)
      end)
    end

    test "recognize returns operation_id" do
      audio = %Plug.Upload{
        path: "/Users/senitapqan/Desktop/elixir/7Easy/test/support/fixtures/my_music_file.m4a",
        filename: "my_music_file.m4a"
      }

      assert {:ok, operation_id} = App.Assembly.SpeechToText.recognize(audio)

      dbg(operation_id)
    end

    test "get_operation_result returns text" do
      # audio = %Plug.Upload{path: "/Users/senitapqan/Desktop/elixir/7Easy/test/support/fixtures/my_music_file.m4a", filename: "my_music_file.m4a"}

      # assert {:ok, operation_id} = App.Assembly.SpeechToText.recognize(audio)

      operation_id = "1eb96a23-d856-4c37-8fea-bb7dc1af7fa6"
      dbg(operation_id)
      assert {:ok, text} = App.Assembly.SpeechToText.get_operation_result(operation_id)
      assert is_binary(text)

      dbg(text)
    end
  end
end

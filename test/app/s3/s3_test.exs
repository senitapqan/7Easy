defmodule App.S3Test do
  use ExUnit.Case, async: true

  describe "Works with real API" do
    @describetag :live_network
    setup do
      old_env = Application.get_env(:seven_easy, :s3_client)
      Application.put_env(:seven_easy, :s3_client, App.S3.S3Client)

      on_exit(fn ->
        Application.put_env(:seven_easy, :s3_client, old_env)
      end)
    end

    test "upload file" do
      bucket = Application.get_env(:seven_easy, :s3_bucket)
      key = "speaking/user_1/speaking_1/question_1.m4a"
      file_path = "/Users/senitapqan/Desktop/elixir/7Easy/test/support/fixtures/my_short_audio_file.m4a"
      assert url = App.S3.upload_file!(bucket, key, file_path)
      assert is_binary(url)

      dbg(url)
    end
  end
end

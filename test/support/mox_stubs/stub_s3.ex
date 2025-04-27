defmodule App.StubS3 do
  @behaviour App.S3

  @impl true
  def upload_file!(_file, _bucket, _key) do
    "https://example.com/file.txt"
  end
end

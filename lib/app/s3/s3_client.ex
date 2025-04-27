defmodule App.S3.S3Client do
  @behaviour App.S3

  @impl true
  def upload_file!(bucket, path, file_path) do
    response =
      file_path
      |> ExAws.S3.Upload.stream_file()
      |> ExAws.S3.upload(bucket, path)
      |> ExAws.request!()

    response.body.location
  end
end

defmodule App.S3 do
  def impl() do
    Application.get_env(
      :seven_easy,
      :s3_client,
      App.S3.S3Client
    )
  end

  @callback upload_file!(bucket :: String.t(), path :: String.t(), file_path :: String.t()) ::
              String.t()

  def upload_file!(bucket, path, file_path) do
    impl().upload_file!(bucket, path, file_path)
  end
end

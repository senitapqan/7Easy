defmodule App.Files do
  alias App.S3

  defp bucket, do: System.get_env("S3_BUCKET")

  def upload_file!(user_id, speaking_id, question_id, tmp_path, ext) do
    key = "speaking/#{user_id}/#{speaking_id}/#{question_id}.#{ext}"

    S3.upload_file!(bucket(), key, tmp_path)
  end
end

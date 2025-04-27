{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start(timeout: :infinity, exclude: [:live_network])
Ecto.Adapters.SQL.Sandbox.mode(App.Repo, :manual)

Mox.defmock(App.MockS3, for: App.S3)
Mox.defmock(App.MockGpt, for: App.OpenAi.Gpt)
Mox.defmock(App.MockSpeechToText, for: App.Assembly.SpeechToText)

Application.put_env(:seven_easy, :s3_client, App.MockS3)
Application.put_env(:seven_easy, :gpt_client, App.MockGpt)
Application.put_env(:seven_easy, :speech_to_text_client, App.MockSpeechToText)

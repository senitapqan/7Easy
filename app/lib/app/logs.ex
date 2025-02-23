defmodule App.Logs do
  alias App.Schema.RequestLog

  def create_request_log!(event, params) do
    %RequestLog{
      event: event,
      params: params
    }
    |> App.Repo.insert!()
  end

end

defmodule App.Schema.RequestLog do
  use App.Schema

  @events [
    :sign_in,
    :sign_up
  ]

  schema "request_logs" do
    field :event, Ecto.Enum, values: @events
    field :params, :map
  end
end

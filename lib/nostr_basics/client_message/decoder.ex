defmodule NostrBasics.ClientMessage.Decoder do
  alias NostrBasics.{Event, Filter, CloseRequest}

  def decode(["EVENT", encoded_event]) do
    Event.decode(encoded_event)
  end

  def decode(["REQ" | [subscription_id | requests]]) do
    requests
    |> Enum.map(&Filter.decode(&1, subscription_id))
  end

  def decode(["CLOSE", subscription_id]) do
    %CloseRequest{subscription_id: subscription_id}
  end

  def decode(_unknown_message) do
    :unknown
  end
end

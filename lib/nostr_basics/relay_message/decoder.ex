defmodule NostrBasics.RelayMessage.Decoder do
  @moduledoc """
  Converts Jason encoded structures into NostrBasics elixir structures
  """

  @doc """
  Converts Jason encoded structures into NostrBasics elixir structures

  ## Examples
      iex> ["EOSE", "b9dcd5af35446678eec7fa6748eb7357"]
      ...> |> NostrBasics.RelayMessage.Decoder.decode()
      {:end_of_stored_events, "b9dcd5af35446678eec7fa6748eb7357"}
  """
  @spec decode(list()) :: {:eose, String.t()}
  def decode(["EOSE", subscription_id]) do
    {:end_of_stored_events, subscription_id}
  end

  def decode(unknown_message) do
    {:unknown, "Unknown nostr message type"}
  end
end

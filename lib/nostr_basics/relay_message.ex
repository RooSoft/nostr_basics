defmodule NostrBasics.RelayMessage do
  @moduledoc """
  A message from a relay to a client

  Specifications here:

  - https://github.com/nostr-protocol/nips/blob/master/01.md#from-relay-to-client-sending-events-and-notices
  - https://github.com/nostr-protocol/nips/blob/master/15.md
  """

  alias NostrBasics.RelayMessage.Decoder

  @doc """
  Converts a client message in string format to the actual related Elixir structure

  ## Examples
      iex> ~s(["EOSE","b9dcd5af35446678eec7fa6748eb7357"])
      ...> |> NostrBasics.RelayMessage.parse()
      {:end_of_stored_events, "b9dcd5af35446678eec7fa6748eb7357"}
  """
  @spec parse(String.t()) :: {:eose, String.t()}
  def parse(message) do
    case Jason.decode(message) do
      {:ok, encoded_message} ->
        Decoder.decode(encoded_message)

      {:error, %Jason.DecodeError{position: position, token: token}} ->
        {:error, "error decoding JSON at position #{position}: #{token}"}
    end
  end
end

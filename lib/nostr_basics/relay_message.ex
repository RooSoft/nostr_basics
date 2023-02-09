defmodule NostrBasics.RelayMessage do
  @moduledoc """
  A message from a relay to a client

  Specifications here:

  - https://github.com/nostr-protocol/nips/blob/master/01.md#from-relay-to-client-sending-events-and-notices
  - https://github.com/nostr-protocol/nips/blob/master/15.md
  """

  alias NostrBasics.Event
  alias NostrBasics.RelayMessage.Decoder

  @doc """
  Converts a client message in string format to the actual related Elixir structure

  ## Examples
      iex> ~s(["EVENT","b9dcd5af35446678eec7fa6748eb7357",{"content":"gm nostr","created_at":1675881420,"id":"c899ed67ac6c736648f1809cf17d187ba2599a7fb2ab85359e19a78cd627a6b9","kind":1,"pubkey":"5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2","sig":"4868c4307638289cd2c3c56aa53eb6ff89372a3ff3b8d744e347889f06bb01e78e0a9704301ea226581e08210984212e275d98fc1d7704406fc4149fb345b19d","tags":[]}])
      ...> |> NostrBasics.RelayMessage.parse()
      {
        :event,
        "b9dcd5af35446678eec7fa6748eb7357",
        %NostrBasics.Event{
          id: "c899ed67ac6c736648f1809cf17d187ba2599a7fb2ab85359e19a78cd627a6b9",
          pubkey: <<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>,
          created_at: ~U[2023-02-08 18:37:00Z],
          kind: 1,
          tags: [],
          content: "gm nostr",
          sig: <<0x4868c4307638289cd2c3c56aa53eb6ff89372a3ff3b8d744e347889f06bb01e78e0a9704301ea226581e08210984212e275d98fc1d7704406fc4149fb345b19d::512>>
        }
      }

      iex> ~s(["NOTICE","a notice from the relay"])
      ...> |> NostrBasics.RelayMessage.parse()
      {:notice, "a notice from the relay"}

      iex> ~s(["EOSE","b9dcd5af35446678eec7fa6748eb7357"])
      ...> |> NostrBasics.RelayMessage.parse()
      {:end_of_stored_events, "b9dcd5af35446678eec7fa6748eb7357"}
  """
  @spec parse(String.t()) ::
          {:event, String.t(), Event.t()}
          | {:notice, String.t()}
          | {:end_of_stored_events, String.t()}
          | {:unknown, String.t()}
  def parse(message) do
    case Jason.decode(message) do
      {:ok, encoded_message} ->
        Decoder.decode(encoded_message)

      {:error, %Jason.DecodeError{position: position, token: token}} ->
        {:error, "error decoding JSON at position #{position}: #{token}"}
    end
  end
end

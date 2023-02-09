defmodule NostrBasics.RelayMessage.Decoder do
  @moduledoc """
  Converts Jason encoded structures into NostrBasics elixir structures
  """

  alias NostrBasics.Event

  @doc """
  Converts Jason encoded structures into NostrBasics elixir structures

  ## Examples
      iex> [
      ...>   "EVENT",
      ...>   "b9dcd5af35446678eec7fa6748eb7357",
      ...>   %{
      ...>     "content" => "gm nostr",
      ...>     "created_at" => 1675881420,
      ...>     "id" => "c899ed67ac6c736648f1809cf17d187ba2599a7fb2ab85359e19a78cd627a6b9",
      ...>     "kind" => 1,
      ...>     "pubkey" => "5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2",
      ...>     "sig" => "4868c4307638289cd2c3c56aa53eb6ff89372a3ff3b8d744e347889f06bb01e78e0a9704301ea226581e08210984212e275d98fc1d7704406fc4149fb345b19d",
      ...>     "tags" => []
      ...>   }
      ...> ]
      ...> |> NostrBasics.RelayMessage.Decoder.decode()
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

      iex> ["NOTICE", "this is a message from the relay"]
      ...> |> NostrBasics.RelayMessage.Decoder.decode()
      {:notice, "this is a message from the relay"}

      iex> ["EOSE", "b9dcd5af35446678eec7fa6748eb7357"]
      ...> |> NostrBasics.RelayMessage.Decoder.decode()
      {:end_of_stored_events, "b9dcd5af35446678eec7fa6748eb7357"}
  """
  @spec decode(list()) ::
          {:event, String.t(), Event.t()}
          | {:notice, String.t()}
          | {:end_of_stored_events, String.t()}
          | {:unknown, String.t()}
  def decode(["EVENT", subscription_id, encoded_event]) do
    event = Event.decode(encoded_event)

    {:event, subscription_id, event}
  end

  def decode(["NOTICE", message]) do
    {:notice, message}
  end

  def decode(["EOSE", subscription_id]) do
    {:end_of_stored_events, subscription_id}
  end

  def decode(_unknown_message) do
    {:unknown, "Unknown nostr message type"}
  end
end

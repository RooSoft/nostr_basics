defmodule NostrBasics.ClientMessage.Decoder do
  @moduledoc """
  Converts Jason encoded structures into NostrBasics elixir structures
  """

  alias NostrBasics.{Event, Filter, CloseRequest}

  @doc """
  Converts Jason encoded structures into NostrBasics elixir structures

  ## Examples
      iex> [
      ...>   "EVENT",
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
      ...> |> NostrBasics.ClientMessage.Decoder.decode()
      {
        :ok,
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

      iex> [
      ...>   "REQ",
      ...>   "7c4924a0d6d3a88917744ea7616618f9",
      ...>   %{
      ...>     "authors" => ["5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2"],
      ...>     "kinds" => [1],
      ...>     "limit" => 10
      ...>   }
      ...> ]
      ...> |> NostrBasics.ClientMessage.Decoder.decode()
      {
        :ok,
        [
          %NostrBasics.Filter{
            subscription_id: "7c4924a0d6d3a88917744ea7616618f9",
            since: nil,
            until: nil,
            limit: 10,
            ids: [],
            authors: [<<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>],
            kinds: [1],
            e: [],
            p: []
          }
        ]
      }

      iex> ["CLOSE", "7c4924a0d6d3a88917744ea7616618f9"]
      ...> |> NostrBasics.ClientMessage.Decoder.decode()
      {
        :ok,
        %NostrBasics.CloseRequest{
          subscription_id: "7c4924a0d6d3a88917744ea7616618f9"
        }
      }

      iex> ~s(["WHAT", "something new"])
      ...> |> NostrBasics.ClientMessage.Decoder.decode()
      {:error, "Unknown nostr message type"}
  """
  @spec decode(list()) ::
          {:ok, Event.t() | list(Filter.t()) | CloseRequest.t()} | {:error, String.t()}
  def decode(["EVENT", encoded_event]) do
    {:ok, Event.decode(encoded_event)}
  end

  def decode(["REQ" | [subscription_id | requests]]) do
    {:ok, Enum.map(requests, &Filter.decode(&1, subscription_id))}
  end

  def decode(["CLOSE", subscription_id]) do
    {:ok, %CloseRequest{subscription_id: subscription_id}}
  end

  def decode(_unknown_message) do
    {:error, "Unknown nostr message type"}
  end
end

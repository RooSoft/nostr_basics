defmodule NostrBasics.Event do
  @moduledoc """
  Represents the basic structure of anything that's being sent to/from relays
  """

  require Logger

  defstruct [:id, :pubkey, :created_at, :kind, :tags, :content, :sig]

  alias NostrBasics.Event
  alias NostrBasics.Event.Parser
  alias NostrBasics.Crypto

  @type t :: %Event{}

  # This thing is needed so that the Jason library knows how to serialize the events
  defimpl Jason.Encoder do
    def encode(
          %Event{
            id: id,
            pubkey: pubkey,
            created_at: created_at,
            kind: kind,
            sig: sig,
            tags: tags,
            content: content
          },
          opts
        ) do
      hex_pubkey = Binary.to_hex(pubkey)
      hex_sig = Binary.to_hex(sig)
      timestamp = DateTime.to_unix(created_at)

      Jason.Encode.map(
        %{
          "id" => id,
          "pubkey" => hex_pubkey,
          "created_at" => timestamp,
          "kind" => kind,
          "tags" => tags,
          "content" => content,
          "sig" => hex_sig
        },
        opts
      )
    end
  end

  @doc """
  Simplifies the creation of an event, adding the created_at and tags fields and
  requiring the bare minimum to do so

  ## Examples
      iex> pubkey = <<0xEFC83F01C8FB309DF2C8866B8C7924CC8B6F0580AFDDE1D6E16E2B6107C2862C::256>>
      ...> NostrBasics.Event.create(1, "this is the content", pubkey)
      %NostrBasics.Event{
        pubkey: <<0xefc83f01c8fb309df2c8866b8c7924cc8b6f0580afdde1d6e16e2b6107c2862c::256>>,
        kind: 1,
        content: "this is the content",
        tags: []
      }
  """
  @spec create(integer(), String.t() | nil, <<_::256>>) :: Event.t()
  def create(kind, content, pubkey) do
    %Event{
      kind: kind,
      pubkey: pubkey,
      content: content,
      tags: []
    }
  end

  @doc """
  Converts a NIP-01 JSON string into a %Event{}

  ## Examples
      iex> ~s({"id":"0f017fc299f6351efe9d5bfbfb36c0c7a1399627f9bec02c49b00d0ec98a5f34","pubkey":"5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2","created_at":1675794272,"kind":1,"tags":[],"content":"this is the content"})
      ...> |> NostrBasics.Event.parse()
      {
        :ok,
        %NostrBasics.Event{
          id: "0f017fc299f6351efe9d5bfbfb36c0c7a1399627f9bec02c49b00d0ec98a5f34",
          pubkey: <<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>,
          created_at: ~U[2023-02-07 18:24:32Z],
          kind: 1,
          tags: [],
          content: "this is the content"
        }
      }
  """
  @spec parse(String.t()) :: {:ok, Event.t()} | {:error, String.t()}
  def parse(body) do
    Parser.parse(body)
  end

  @doc """
  Converts a NIP-01 JSON string decoded as a map by Jason into an %Event{}

  ## Examples
      iex> %{
      ...>    "content" => "this is the content",
      ...>    "created_at" => 1675794272,
      ...>    "id" => "0f017fc299f6351efe9d5bfbfb36c0c7a1399627f9bec02c49b00d0ec98a5f34",
      ...>    "kind" => 1,
      ...>    "pubkey" => "5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2",
      ...>    "tags" => []
      ...>  }
      ...> |> NostrBasics.Event.decode()
      %NostrBasics.Event{
        id: "0f017fc299f6351efe9d5bfbfb36c0c7a1399627f9bec02c49b00d0ec98a5f34",
        pubkey: <<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>,
        created_at: ~U[2023-02-07 18:24:32Z],
        kind: 1,
        tags: [],
        content: "this is the content"
      }
  """
  def decode(raw_event) when is_map(raw_event) do
    Parser.decode(raw_event)
  end

  @doc """
  Adds an ID to an event that doesn't have one

  ## Examples
      iex> %NostrBasics.Event{
      ...>   pubkey: <<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>,
      ...>   created_at: ~U[2023-02-07 18:24:32Z],
      ...>   kind: 1,
      ...>   tags: [],
      ...>   content: "this is the content"
      ...> }
      ...> |> NostrBasics.Event.add_id
      %NostrBasics.Event{
        id: "0f017fc299f6351efe9d5bfbfb36c0c7a1399627f9bec02c49b00d0ec98a5f34",
        pubkey: <<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>,
        created_at: ~U[2023-02-07 18:24:32Z],
        kind: 1,
        tags: [],
        content: "this is the content"
      }
  """
  @spec add_id(Event.t()) :: Event.t()
  def add_id(event) do
    id = create_id(event)

    %{event | id: id}
  end

  @doc """
  Creates an ID for an event that doesn't have one

  ## Examples
      iex> %NostrBasics.Event{
      ...>   pubkey: <<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>,
      ...>   created_at: ~U[2023-02-07 18:24:32Z],
      ...>   kind: 1,
      ...>   tags: [],
      ...>   content: "this is the content"
      ...> }
      ...> |> NostrBasics.Event.create_id
      "0f017fc299f6351efe9d5bfbfb36c0c7a1399627f9bec02c49b00d0ec98a5f34"
  """
  @spec create_id(Event.t()) :: String.t()
  def create_id(%Event{} = event) do
    event
    |> json_for_id()
    |> Crypto.sha256()
    |> Binary.to_hex()
  end

  @doc """
  A structure an event has to be converted to prior to being SHA256'd, mainly for ID creation

  ## Examples
      iex> %NostrBasics.Event{
      ...>   pubkey: <<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>,
      ...>   created_at: ~U[2023-02-07 18:24:32Z],
      ...>   kind: 1,
      ...>   tags: [],
      ...>   content: "this is the content"
      ...> }
      ...> |> NostrBasics.Event.json_for_id
      ~s([0,"5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2",1675794272,1,[],"this is the content"])
  """
  @spec json_for_id(Event.t()) :: String.t()
  def json_for_id(%Event{
        pubkey: pubkey,
        created_at: created_at,
        kind: kind,
        tags: tags,
        content: content
      }) do
    hex_pubkey = Binary.to_hex(pubkey)
    timestamp = DateTime.to_unix(created_at)

    [
      0,
      hex_pubkey,
      timestamp,
      kind,
      tags,
      content
    ]
    |> Jason.encode!()
  end
end

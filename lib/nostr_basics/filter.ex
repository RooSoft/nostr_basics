defmodule NostrBasics.Filter do
  @moduledoc """
  Details of a client subscription request to a relay
  """

  defstruct [
    :subscription_id,
    :since,
    :until,
    :limit,
    ids: [],
    authors: [],
    kinds: [],
    e: [],
    p: []
  ]

  alias NostrBasics.Filter
  alias NostrBasics.Filter.{Parser, Serializer}

  @type t :: %Filter{}

  defimpl Jason.Encoder do
    def encode(
          %Filter{
            since: since,
            until: until,
            limit: limit,
            ids: ids,
            authors: authors,
            kinds: kinds,
            e: e,
            p: p
          },
          opts
        ) do
      since_timestamp = to_timestamp(since)
      hex_authors = to_hex(authors)

      Jason.Encode.map(
        %{
          "since" => since_timestamp,
          "until" => until,
          "limit" => limit,
          "ids" => ids,
          "authors" => hex_authors,
          "kinds" => kinds,
          "e" => e,
          "p" => p
        }
        |> Map.filter(fn {_, v} -> v != nil end)
        |> Map.filter(fn {_, v} -> v != [] end),
        opts
      )
    end

    defp to_timestamp(nil), do: nil
    defp to_timestamp(date), do: DateTime.to_unix(date)

    defp to_hex(nil), do: nil

    defp to_hex(binaries) when is_list(binaries) do
      binaries
      |> Enum.map(&Binary.to_hex/1)
    end
  end

  @doc """
  Converts a NIP-01 JSON REQ string into a structured Filter

  ## Examples
      iex> ~s({"authors":["5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2"],"kinds":[1],"limit":10})
      ...> |> NostrBasics.Filter.from_req("a_subscription_id")
      {
        :ok,
        %NostrBasics.Filter{
          subscription_id: "a_subscription_id",
          kinds: [1],
          authors: [<<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>],
          limit: 10
        }
      }
  """
  @spec from_req(String.t(), String.t()) :: {:ok, Filter.t()} | {:error, String.t()}
  def from_req(req, subscription_id) do
    Parser.from_req(req, subscription_id)
  end

  @doc """
  Converts a JSON decoded encoded filter into a %Filter{}

  ## Examples
      iex> %{
      ...>   "authors" => ["5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2"],
      ...>   "kinds" => [1],
      ...>   "limit" => 10
      ...> }
      ...> |> NostrBasics.Filter.decode("a_subscription_id")
      %NostrBasics.Filter{
        subscription_id: "a_subscription_id",
        kinds: [1],
        authors: [<<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>],
        limit: 10
      }
  """
  def decode(encoded_request, subscription_id) do
    Parser.decode(encoded_request, subscription_id)
  end

  @doc """
  Converts a structured Filter into a NIP-01 JSON REQ string

  ## Examples
      iex> %NostrBasics.Filter{
      ...>   subscription_id: "a_subscription_id",
      ...>   kinds: [1],
      ...>   authors: [<<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>],
      ...>   limit: 10
      ...> }
      ...> |> NostrBasics.Filter.to_query
      {
        :ok,
        ~s({"authors":["5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2"],"kinds":[1],"limit":10})
      }
  """
  @spec to_query(Filter.t()) :: {:ok, String.t()} | {:error, String.t()}
  def to_query(filter) do
    Serializer.to_req(filter)
  end
end

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
  alias NostrBasics.Filter.Parser

  @type t :: %Filter{}

  @doc """
  ## Examples
    iex> ~s({"authors":["5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2"],"kinds":[1],"limit":10})
    ...> |> NostrBasics.Filter.from_query("a_subscription_id")
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
  @spec from_query(String.t(), String.t()) :: Filter.t()
  def from_query(req, subscription_id) do
    Parser.from_req(req, subscription_id)
  end
end

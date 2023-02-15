defmodule NostrBasics.Filter.Parser do
  @moduledoc """
  Converts a string request to a structured subscription filter and back
  """

  alias NostrBasics.Filter

  @doc """
  ## Examples
      iex> ~s({"authors":["5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2"],"kinds":[1],"limit":10})
      ...> |> NostrBasics.Filter.Parser.from_req("a_subscription_id")
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
    case Jason.decode(req) do
      {:ok, encoded_request} ->
        {
          :ok,
          decode(encoded_request, subscription_id)
        }

      {:error, %Jason.DecodeError{position: position, token: token}} ->
        {:error, "error decoding JSON at position #{position}: #{token}"}
    end
  end

  @doc """
  Converts a JSON decoded encoded filter into a %Filter{}

  ## Examples
      iex> %{
      ...>   "authors" => ["5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2"],
      ...>   "kinds" => [1],
      ...>   "limit" => 10
      ...> }
      ...> |> NostrBasics.Filter.Parser.decode("a_subscription_id")
      %NostrBasics.Filter{
        subscription_id: "a_subscription_id",
        kinds: [1],
        authors: [<<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>],
        limit: 10
      }
  """
  def decode(encoded_request, subscription_id) do
    %Filter{
      subscription_id: subscription_id,
      since: Map.get(encoded_request, "since"),
      until: Map.get(encoded_request, "until"),
      limit: Map.get(encoded_request, "limit"),
      ids: Map.get(encoded_request, "ids") || [],
      authors: get_authors(encoded_request),
      kinds: Map.get(encoded_request, "kinds"),
      e: Map.get(encoded_request, "e") || [],
      p: Map.get(encoded_request, "p") || []
    }
  end

  defp get_authors(request) do
    case Map.get(request, "authors") do
      nil -> []
      authors -> Enum.map(authors, &Binary.from_hex/1)
    end
  end
end

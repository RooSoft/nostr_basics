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
      {:ok, request} ->
        {
          :ok,
          %Filter{
            subscription_id: subscription_id,
            since: Map.get(request, "since"),
            until: Map.get(request, "until"),
            limit: Map.get(request, "limit"),
            ids: Map.get(request, "ids") || [],
            authors: get_authors(request),
            kinds: Map.get(request, "kinds"),
            e: Map.get(request, "e") || [],
            p: Map.get(request, "p") || []
          }
        }

      {:error, %Jason.DecodeError{position: position, token: token}} ->
        {:error, "error decoding JSON at position #{position}: #{token}"}
    end
  end

  defp get_authors(request) do
    Map.get(request, "authors")
    |> Enum.map(&Binary.from_hex/1)
  end
end

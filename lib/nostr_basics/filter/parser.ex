defmodule NostrBasics.Filter.Parser do
  alias NostrBasics.Filter

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

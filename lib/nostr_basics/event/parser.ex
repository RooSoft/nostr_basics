defmodule NostrBasics.Event.Parser do
  @moduledoc """
  Turns raw events from JSON websocket messages into elixir structs
  """

  alias NostrBasics.Event

  @spec parse(String.t()) :: {:ok, Event.t()} | {:error, String.t()}
  def parse(json_event) when is_binary(json_event) do
    case Jason.decode(json_event) do
      {:ok, event} ->
        {:ok, decode_event_hash(event)}

      {:error, %Jason.DecodeError{position: position, token: token}} ->
        {:error, "error decoding JSON at position #{position}: #{token}"}
    end
  end

  defp decode_event_hash(hash) do
    pubkey = hash |> Map.get("pubkey") |> to_binary
    sig = hash |> Map.get("sig") |> to_binary

    created_at = hash |> Map.get("created_at") |> parse_created_at()
    content = hash |> Map.get("content")

    %Event{
      id: Map.get(hash, "id"),
      content: content,
      created_at: created_at,
      kind: Map.get(hash, "kind"),
      pubkey: pubkey,
      sig: sig,
      tags: Map.get(hash, "tags")
    }
  end

  defp parse_created_at(unix_created_at) do
    case DateTime.from_unix(unix_created_at) do
      {:ok, created_at} -> created_at
      {:error, _message} -> nil
    end
  end

  defp to_binary(nil), do: nil
  defp to_binary(value), do: Binary.from_hex(value)
end

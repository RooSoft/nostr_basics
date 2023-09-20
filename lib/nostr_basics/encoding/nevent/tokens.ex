defmodule NostrBasics.Encoding.Nevent.Tokens do
  @moduledoc """
  Converts an encoded event id into tokens with specific meanings
  """

  @nevent "nevent"

  @doc """
  Extract tokens from a bech32 encoded string

  ## Examples
      iex> "nevent1qqs0mn6wju0teknamedkkgfsfyk0n8743slca8x929yc7p5z42n5gvqpz3mhxue69uhhyetvv9ujuerpd46hxtnfdupzphchxfm3ste32hfhkvczzxapme9gz5qvqtget6tylyd7wa8vjecgqvzqqqqqqysdssmq"
      ...> |> NostrBasics.Encoding.Nevent.Tokens.extract
      {
        :ok, 
        [
          {
            0, 
            <<253, 207, 78, 151, 30, 188, 218, 125, 222, 91, 107, 33, 48, 73, 44, 249, 159, 213, 140, 63, 142, 156, 197, 81, 73, 143, 6, 130, 170, 167, 68, 48>>
          }, 
          {
            1, 
            "wss://relay.damus.io"
          }, 
          {
            2,
            <<223, 23, 50, 119, 24, 47, 49, 85, 211, 123, 51, 2, 17, 186, 29, 228, 168, 21, 0, 192, 45, 25, 94, 150, 79, 145, 190, 119, 78, 201, 103, 8>>
          }, 
          {
            3, 
            <<0, 0, 0, 1>>
          }
        ]
      }
  """
  @spec extract(binary()) :: {:ok, binary(), binary()} | {:error, atom()}
  def extract(encoded) do
    case Bech32.decode(encoded) do
      {:ok, @nevent, data} ->
        extract_tokens([], data)

      {:error, message} ->
        {:error, message}
    end
  end

  defp extract_tokens(tokens, <<>>) do
    {
      :ok,
      tokens
      |> Enum.map(fn {type, data, _rest} -> {type, data} end)
      |> Enum.reverse()
    }
  end

  defp extract_tokens(tokens, <<type::8, length::8, rest::binary>>) do
    <<data::binary-size(length), rest::binary>> = rest

    extract_tokens([{type, data, rest} | tokens], rest)
  end

  defp extract_tokens(_, _), do: {:error, :malformed}
end

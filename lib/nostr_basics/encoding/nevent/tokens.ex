defmodule NostrBasics.Encoding.Nevent.Tokens do
  @nevent "nevent"

  def extract(encoded) do
    case Bech32.decode(encoded) do
      {:ok, @nevent, data} ->
        extract_tokens([], data)

      {:error, message} ->
        {:error, message}
    end
  end

  defp extract_tokens(tokens, <<>>), do: {:ok, Enum.reverse(tokens)}

  defp extract_tokens(tokens, <<type::8, length::8, rest::binary>>) do
    <<data::binary-size(length), rest::binary>> = rest

    extract_tokens([{type, data, rest} | tokens], rest)
  end

  defp extract_tokens(_, _), do: {:error, :malformed}
end

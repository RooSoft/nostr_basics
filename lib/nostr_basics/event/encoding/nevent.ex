defmodule NostrBasics.Encoding.Nevent do
  defstruct [:id, :kind, :author, relays: []]

  alias NostrBasics.Encoding.Nevent

  @type t :: %Nevent{}

  @nevent "nevent"
  @special 0
  @relay 1
  @author 2
  @kind 3

  @doc """
  ## Examples
      iex> "nevent1qqs0mn6wju0teknamedkkgfsfyk0n8743slca8x929yc7p5z42n5gvqpz3mhxue69uhhyetvv9ujuerpd46hxtnfdupzphchxfm3ste32hfhkvczzxapme9gz5qvqtget6tylyd7wa8vjecgqvzqqqqqqysdssmq"
      ...> |> NostrBasics.Encoding.Nevent.decode 
      {
        :ok,
        %NostrBasics.Encoding.Nevent{
          author: <<223, 23, 50, 119, 24, 47, 49, 85, 211, 123, 51, 2, 17, 186, 29, 228, 168, 21, 0, 192, 45, 25, 94, 150, 79, 145, 190, 119, 78, 201, 103, 8>>,
          id: <<253, 207, 78, 151, 30, 188, 218, 125, 222, 91, 107, 33, 48, 73, 44, 249, 159, 213, 140, 63, 142, 156, 197, 81, 73, 143, 6, 130, 170, 167, 68, 48>>,
          kind: 1,
          relays: ["wss://relay.damus.io"]
        }
      }
  """

  @spec decode(binary()) :: {:ok, Nevent.t()} | {:error, atom()}
  def decode(@nevent <> _ = encoded) do
    with {:ok, tokens} <- tokenize(encoded),
         {:ok, nevent} <- to_struct(tokens) do
      {:ok, nevent}
    else
      {:error, message} -> {:error, message}
    end
  end

  defp tokenize(encoded) do
    case Bech32.decode(encoded) do
      {:ok, @nevent, data} ->
        extract_tokens([], data)
    end
  end

  defp extract_tokens(tokens, <<>>), do: {:ok, Enum.reverse(tokens)}

  defp extract_tokens(tokens, <<type::8, length::8, rest::binary>>) do
    <<data::binary-size(length), rest::binary>> = rest

    extract_tokens([{type, data, rest} | tokens], rest)
  end

  defp extract_tokens(_, _), do: {:error, :malformed}

  defp to_struct(tokens) do
    nevent =
      Enum.reduce(tokens, %Nevent{}, fn {type, data, _}, nevent ->
        nevent
        |> add_property(type, data)
      end)

    {:ok, nevent}
  end

  defp add_property(%Nevent{} = nevent, @special, <<id::binary-32>>) do
    %{nevent | id: id}
  end

  defp add_property(%Nevent{} = nevent, @relay, url) do
    %{nevent | relays: [url | nevent.relays]}
  end

  defp add_property(%Nevent{} = nevent, @author, id) do
    %{nevent | author: id}
  end

  defp add_property(%Nevent{} = nevent, @kind, <<kind::32>>) do
    %{nevent | kind: kind}
  end
end

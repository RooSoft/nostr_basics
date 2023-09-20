defmodule NostrBasics.Encoding.Nevent do
  defstruct [:id, :kind, :author, relays: []]

  alias NostrBasics.Encoding.Nevent
  alias NostrBasics.Encoding.Nevent.{Properties, Tokens}

  @type t :: %Nevent{}

  @nevent "nevent"

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

      iex> "nevent1asdf"
      ...> |> NostrBasics.Encoding.Nevent.decode()
      {:error, :malformed}
  """

  @spec decode(binary()) :: {:ok, Nevent.t()} | {:error, atom()}
  def decode(@nevent <> _ = encoded) do
    with {:ok, tokens} <- Tokens.extract(encoded),
         {:ok, nevent} <- to_struct(tokens) do
      {:ok, nevent}
    else
      {:error, :too_long} -> {:error, :malformed}
      {:error, message} -> {:error, message}
    end
  end

  defp to_struct(tokens) do
    nevent =
      Enum.reduce(tokens, %Nevent{}, fn {type, data, _}, nevent ->
        Properties.add(nevent, type, data)
      end)

    {:ok, nevent}
  end
end

defmodule NostrBasics.Encoding.Nevent.Instance do
  @moduledoc """
  Converts %Nevent{} instances into tokens and back, intermediary step for bech32 identifiers
  """

  alias NostrBasics.Encoding.Nevent

  @special 0
  @relay 1
  @author 2
  @kind 3

  @doc """
  Converts a set of tokens into a %Nevent{}

  ## Examples
      iex> [
      ...>   {0, <<0xfdcf4e971ebcda7dde5b6b2130492cf99fd58c3f8e9cc551498f0682aaa74430::256>>},
      ...>   {1, "wss://relay.damus.io"},
      ...>   {2, <<0xdf173277182f3155d37b330211ba1de4a81500c02d195e964f91be774ec96708::256>>},
      ...>   {3, <<1::32>>}
      ...> ]
      ...> |> NostrBasics.Encoding.Nevent.Instance.from_tokens()
      {
        :ok,
        %NostrBasics.Encoding.Nevent{
          author: <<0xdf173277182f3155d37b330211ba1de4a81500c02d195e964f91be774ec96708::256>>,
          id: <<0xfdcf4e971ebcda7dde5b6b2130492cf99fd58c3f8e9cc551498f0682aaa74430::256>>,
          kind: 1,
          relays: ["wss://relay.damus.io"]
        }
      }
  """
  def from_tokens(tokens) do
    nevent =
      Enum.reduce(tokens, %Nevent{}, fn {type, data}, nevent ->
        add_token(nevent, type, data)
      end)

    {:ok, nevent}
  end

  @doc """
  Converts an NEvent into relay_tokens

  ## Examples
      iex> %NostrBasics.Encoding.Nevent{
      ...>   author: <<0xdf173277182f3155d37b330211ba1de4a81500c02d195e964f91be774ec96708::256>>,
      ...>   id: <<0xfdcf4e971ebcda7dde5b6b2130492cf99fd58c3f8e9cc551498f0682aaa74430::256>>,
      ...>   kind: 1,
      ...>   relays: ["wss://relay.damus.io"]
      ...> }
      ...> |> NostrBasics.Encoding.Nevent.Instance.to_tokens()
      [
        {0, <<0xfdcf4e971ebcda7dde5b6b2130492cf99fd58c3f8e9cc551498f0682aaa74430::256>>},
        {1, "wss://relay.damus.io"},
        {2, <<0xdf173277182f3155d37b330211ba1de4a81500c02d195e964f91be774ec96708::256>>},
        {3, <<1::32>>}
      ]
  """
  @spec to_tokens(Nevent.t()) :: list()
  def to_tokens(%Nevent{id: id, kind: kind, author: author, relays: relays}) do
    relay_tokens =
      relays
      |> Enum.map(&({@relay, &1}))

    [{ @special, id }] ++ relay_tokens ++ [{@author, author}] ++ [{@kind, <<kind::32>>}]
  end

  defp add_token(%Nevent{} = nevent, @special, <<id::binary-32>>) do
    %{nevent | id: id}
  end

  defp add_token(%Nevent{} = nevent, @relay, url) do
    %{nevent | relays: [url | nevent.relays]}
  end

  defp add_token(%Nevent{} = nevent, @author, id) do
    %{nevent | author: id}
  end

  defp add_token(%Nevent{} = nevent, @kind, <<kind::32>>) do
    %{nevent | kind: kind}
  end
end

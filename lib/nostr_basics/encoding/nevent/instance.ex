defmodule NostrBasics.Encoding.Nevent.Instance do
  alias NostrBasics.Encoding.Nevent

  @special 0
  @relay 1
  @author 2
  @kind 3

  def from_tokens(tokens) do
    nevent =
      Enum.reduce(tokens, %Nevent{}, fn {type, data, _}, nevent ->
        add_token(nevent, type, data)
      end)

    {:ok, nevent}
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

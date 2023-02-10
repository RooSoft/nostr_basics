defimpl Inspect, for: NostrBasics.Event do
  alias NostrBasics.HexBinary

  def inspect(%NostrBasics.Event{} = event, opts) do
    %{
      event
      | pubkey: %HexBinary{data: event.pubkey},
        sig: %HexBinary{data: event.sig}
    }
    |> Inspect.Any.inspect(opts)
  end
end

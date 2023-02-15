defimpl Inspect, for: NostrBasics.Filter do
  alias NostrBasics.{Filter, HexBinary}

  def inspect(
        %Filter{ids: raw_ids, authors: raw_authors, e: raw_e_list, p: raw_p_list} = filter,
        opts
      ) do
    %{
      filter
      | ids: inspect_identifier_list(raw_ids),
        authors: inspect_identifier_list(raw_authors),
        e: inspect_identifier_list(raw_e_list),
        p: inspect_identifier_list(raw_p_list)
    }
    |> Inspect.Any.inspect(opts)
  end

  defp inspect_identifier_list(nil), do: []

  defp inspect_identifier_list(raw_identifiers) do
    raw_identifiers
    |> Enum.map(fn identifier -> %HexBinary{data: identifier} end)
  end
end

defmodule NostrBasics.Filter.Serializer do
  @doc """
  Converts a structured Filter into a NIP-01 JSON REQ string

  ## Examples
      iex> %NostrBasics.Filter{
      ...>   subscription_id: "a_subscription_id",
      ...>   kinds: [1],
      ...>   authors: [<<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>],
      ...>   limit: 10
      ...> }
      ...> |> NostrBasics.Filter.Serializer.to_req
      {
        :ok,
        ~s({"authors":["5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2"],"kinds":[1],"limit":10})
      }
  """
  @spec to_req(Filter.t()) :: {:ok, String.t()} | {:error, String.t()}
  def to_req(filter) do
    Jason.encode(filter)
  end
end

defmodule NostrBasics.Models.Profile.Convert do
  @moduledoc """
  Convert a profile model to a nostr event
  """

  alias NostrBasics.Keys.PublicKey
  alias NostrBasics.Event

  alias NostrBasics.Models.Profile

  @reaction_kind 0

  @doc """
  Creates a new nostr profile

  Can't do a detailed doctest because the encoded content can change order and thus is non-deterministic

  ## Examples
      iex> %NostrBasics.Models.Profile{
      ...>   about: "some user description",
      ...>   banner: "https://image.com/satoshi_banner",
      ...>   display_name: "satoshi nakamoto",
      ...>   lud16: "satoshi@nakamoto.jp",
      ...>   name: "satoshi nakamoto",
      ...>   nip05: "_@nakamoto.jp",
      ...>   picture: "https://image.com/satoshi_avatar",
      ...>   website: "https://bitcoin.org"
      ...> }
      ...> |> NostrBasics.Models.Profile.Convert.to_event(<<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>)
      ...> |> elem(0)
      :ok
  """
  @spec to_event(Profile.t(), PublicKey.id()) :: {:ok, Event.t()} | {:error, String.t()}
  def to_event(%Profile{} = profile, pubkey) do
    case Jason.encode(profile) do
      {:ok, json_profile} ->
        {
          :ok,
          Event.create(@reaction_kind, json_profile, pubkey)
        }

      {:error, message} ->
        {:error, message}
    end
  end
end

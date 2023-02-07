defmodule NostrBasics.Event.Signer do
  @moduledoc """
  Signs events, making sure they're going to be accepted on the nostr network as the user's own
  """

  alias NostrBasics.Event
  alias K256.Schnorr

  @doc """
  Applies the schnorr signatures to an event and adds signature to it if successful

  ## Examples
      iex> private_key = <<0x4e22da43418dd934373cbb38a5ab13059191a2b3a51c5e0b67eb1334656943b8::256>>
      ...> %NostrBasics.Event{
      ...>   id: "79d747b040a30fceb446c6ac34936cb93ac2d520a682b8096238f868c4ff5e5c",
      ...>   pubkey: <<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>,
      ...>   kind: 1,
      ...>   created_at: ~U[2023-02-07 18:24:32.596503Z],
      ...>   tags: [],
      ...>   content: "this is the content"
      ...> }
      ...> |> NostrBasics.Event.Signer.sign_event(private_key)
      {
        :ok,
        %NostrBasics.Event{
          id: "79d747b040a30fceb446c6ac34936cb93ac2d520a682b8096238f868c4ff5e5c",
          pubkey: <<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>,
          created_at: ~U[2023-02-07 18:24:32.596503Z],
          kind: 1,
          tags: [],
          content: "this is the content",
          sig: <<0x985a5ffea93ccebaab4875c973186fac0e066a26222ddf932b8b5a98782a181baa1496394b13134e74f86a8b816bfccff152c7e66ef02e72bb9ae7db8d843680::512>>
        }
      }
  """
  @spec sign_event(Event.t(), <<_::256>>) :: {:ok, Event.t()} | {:error, String.t()}
  def sign_event(%Event{id: _id} = event, privkey) do
    json_for_id = Event.json_for_id(event)

    case Schnorr.create_signature(json_for_id, privkey) do
      {:ok, sig} -> {:ok, %{event | sig: sig}}
      {:error, message} when is_atom(message) -> {:error, Atom.to_string(message)}
    end
  end
end

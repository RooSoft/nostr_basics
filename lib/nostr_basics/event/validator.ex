defmodule NostrBasics.Event.Validator do
  @moduledoc """
  Makes sure a signature is valid
  """

  alias K256.Schnorr
  alias NostrBasics.Event

  @doc """
  Applies Schnorr signatures with the public key and the signature, making sure the event
  is properly signed

  ## Examples
      iex> %NostrBasics.Event{
      ...>   id: "0f017fc299f6351efe9d5bfbfb36c0c7a1399627f9bec02c49b00d0ec98a5f34",
      ...>   pubkey: <<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>,
      ...>   created_at: ~U[2023-02-07 18:24:32.596503Z],
      ...>   kind: 1,
      ...>   tags: [],
      ...>   content: "this is the content",
      ...>   sig: <<0x985a5ffea93ccebaab4875c973186fac0e066a26222ddf932b8b5a98782a181baa1496394b13134e74f86a8b816bfccff152c7e66ef02e72bb9ae7db8d843680::512>>
      ...> }
      ...> |> NostrBasics.Event.Validator.validate_event()
      :ok
  """
  @spec validate_event(Event.t()) :: :ok | {:error, String.t()}
  def validate_event(%Event{} = event) do
    with :ok <- validate_id(event),
         :ok <- validate_signature(event) do
      :ok
    else
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Recreates the event's ID and makes sur it's the same as the one already in the structure

  ## Examples
      iex> %NostrBasics.Event{
      ...>   id: "0f017fc299f6351efe9d5bfbfb36c0c7a1399627f9bec02c49b00d0ec98a5f34",
      ...>   pubkey: <<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>,
      ...>   created_at: ~U[2023-02-07 18:24:32.596503Z],
      ...>   kind: 1,
      ...>   tags: [],
      ...>   content: "this is the content"
      ...> }
      ...> |> NostrBasics.Event.Validator.validate_id()
      :ok

      iex> %NostrBasics.Event{
      ...>   id: "0000f",
      ...>   pubkey: <<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>,
      ...>   created_at: ~U[2023-02-07 18:24:32.596503Z],
      ...>   kind: 1,
      ...>   tags: [],
      ...>   content: "this is the content"
      ...> }
      ...> |> NostrBasics.Event.Validator.validate_id()
      {:error, "generated ID and the one in the event don't match"}
  """
  @spec validate_id(Event.t()) :: :ok | {:error, String.t()}
  def validate_id(%Event{id: id} = event) do
    case id == Event.create_id(event) do
      true -> :ok
      false -> {:error, "generated ID and the one in the event don't match"}
    end
  end

  @spec validate_signature(Event.t()) :: :ok | {:error, atom()}
  def validate_signature(%Event{id: hex_id, sig: sig, pubkey: pubkey}) do
    id = Binary.from_hex(hex_id)

    Schnorr.verify_message_digest(id, sig, pubkey)
  end
end

defmodule NostrBasics.Models.Note do
  @moduledoc """
  Note struct and manipulation functions
  """

  defstruct [:content]

  alias NostrBasics.Event
  alias NostrBasics.Keys.PublicKey
  alias NostrBasics.Models.Note

  @type t :: %Note{}
  @type id :: String.t() | <<_::256>>

  @doc """
  Creates a new nostr note

  ## Examples
      iex> %NostrBasics.Models.Note{
      ...>   content: "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks"
      ...> }
      ...> |> NostrBasics.Models.Note.to_event(<<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>)
      {
        :ok,
        %NostrBasics.Event{
          pubkey: <<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>,
          kind: 1,
          content: "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks",
          tags: []
        }
      }
  """
  @spec to_event(Note.t(), PublicKey.id()) :: {:ok, Event.t()} | {:error, String.t()}
  def to_event(note, pubkey) do
    Note.Convert.to_event(note, pubkey)
  end

  @doc """
  Creates a bech32 id for a note

  ## Examples
      iex> NostrBasics.Models.Note.id_to_bech32("260056ba2ac10204aa36d5563ead985be52c4f039ade8ef66c36a29e9f1450e4")
      "note1ycq9dw32cypqf23k64tratvct0jjcncrnt0gaanvx63fa8c52rjqw0pj56"

      iex> NostrBasics.Models.Note.id_to_bech32(<<0x260056ba2ac10204aa36d5563ead985be52c4f039ade8ef66c36a29e9f1450e4::256>>)
      "note1ycq9dw32cypqf23k64tratvct0jjcncrnt0gaanvx63fa8c52rjqw0pj56"
  """
  @spec id_to_bech32(binary()) :: binary()
  def id_to_bech32(<<_::256>> = id), do: Bech32.encode("note", id)
  def id_to_bech32(id), do: Bech32.encode("note", Binary.from_hex(id))
end

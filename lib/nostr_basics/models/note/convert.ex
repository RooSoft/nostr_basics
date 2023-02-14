defmodule NostrBasics.Models.Note.Convert do
  @moduledoc """
  Convert a note model to a nostr event
  """


  alias NostrBasics.Keys.PublicKey
  alias NostrBasics.Event

  alias NostrBasics.Models.Note

  @note_kind 1

  @doc """
  Creates a new nostr note

  ## Examples
      iex> %NostrBasics.Models.Note{
      ...>   content: "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks"
      ...> }
      ...> |> NostrBasics.Models.Note.Convert.to_event(<<0x5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2::256>>)
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
  @spec to_event(Note.t(), PublicKey.t()) :: {:ok, Event.t()} | {:error, String.t()}
  def to_event(%Note{content: content}, note_pubkey) do
    {
      :ok,
      Event.create(@note_kind, content, note_pubkey)
    }
  end
end

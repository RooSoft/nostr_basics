# NostrBasics

Basic structures both useful for nostr relays and clients

Takes care of:

- Keys
  - Private keys
  - Public keys

- Client nostr messages
  - Event
  - Req
  - Close

- Relay nostr messages
  - Event
  - Notice
  - EOSE

- Cryptography
  - SHA256
  - Schnorr Signatures

- Events
  - Parsing
  - Serialization
  - Signing
  - Validation

- Filters
  - Parsing
  - Serialization

## Installation

The package can be installed by adding `nostr_basics` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:nostr_basics, "~> 0.1.4"}
  ]
end
```


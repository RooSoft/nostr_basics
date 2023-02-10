defmodule NostrBasics.Crypto.AES256CBC do
  @moduledoc """
  Algorithm that encrypts and decrypts direct messages
  """

  @doc """
  Encrypts a direct message

  The example below can't test for the result, as it changes on every execution...

  ## Examples
      iex> remote_public_key = <<0xEFC83F01C8FB309DF2C8866B8C7924CC8B6F0580AFDDE1D6E16E2B6107C2862C::256>>
      ...> local_private_key = <<0x4E22DA43418DD934373CBB38A5AB13059191A2B3A51C5E0B67EB1334656943B8::256>>
      ...> "this message will end up being encrypted"
      ...> |> NostrBasics.Crypto.AES256CBC.encrypt(local_private_key, remote_public_key)
  """
  @spec encrypt(String.t(), <<_::256>>, <<_::256>>) :: String.t()
  def encrypt(message, seckey, pubkey) do
    iv = :crypto.strong_rand_bytes(16)

    shared_secret = get_shared_secret(seckey, pubkey)

    cipher_text =
      :crypto.crypto_one_time(:aes_256_cbc, shared_secret, iv, message,
        encrypt: true,
        padding: :pkcs_padding
      )

    b64_cypher_text = Base.encode64(cipher_text)
    b64_iv = Base.encode64(iv)

    "#{b64_cypher_text}?iv=#{b64_iv}"
  end

  @doc """
  Decrypts a direct message

  ## Examples
      iex> remote_public_key = <<0xEFC83F01C8FB309DF2C8866B8C7924CC8B6F0580AFDDE1D6E16E2B6107C2862C::256>>
      ...> local_private_key = <<0x4E22DA43418DD934373CBB38A5AB13059191A2B3A51C5E0B67EB1334656943B8::256>>
      ...> "sWLtVbabr8fzIugnOXo4og==?iv=nxF/xVqbC4JdMRUEC0Jfyg=="
      ...> |> NostrBasics.Crypto.AES256CBC.decrypt(local_private_key, remote_public_key)
      {:ok, "test"}
  """
  @spec decrypt(String.t(), <<_::256>>, <<_::256>>) ::
          {:ok, String.t()} | {:error, atom() | String.t()}
  def decrypt(message, seckey, pubkey) do
    [message, iv] = String.split(message, "?iv=")

    with {:ok, message} <- Base.decode64(message),
         {:ok, iv} <- Base.decode64(iv) do
      shared_secret = get_shared_secret(seckey, pubkey)

      decrypted =
        :crypto.crypto_one_time(:aes_256_cbc, shared_secret, iv, message,
          encrypt: false,
          padding: :pkcs_padding
        )

      {:ok, decrypted}
    else
      {:error, message} -> {:error, message}
      :error -> {:error, "cannot decode iv, which should be in base64"}
    end
  end

  defp get_shared_secret(<<_::256>> = seckey, <<_::256>> = pubkey) do
    :crypto.compute_key(
      :ecdh,
      <<0x02::8, pubkey::bitstring-256>>,
      seckey,
      :secp256k1
    )
  end
end

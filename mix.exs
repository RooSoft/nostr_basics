defmodule NostrBasics.MixProject do
  use Mix.Project

  def project do
    [
      app: :nostr_basics,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.4"},
      {:k256, "~> 0.0.7"},
      {:binary, "~> 0.0.5"},
      {:bech32, "~> 1.0"}
    ]
  end
end

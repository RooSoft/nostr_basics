defmodule NostrBasics.MixProject do
  use Mix.Project

  @version "0.0.15"

  def project do
    [
      app: :nostr_basics,
      version: @version,
      description: "Basic structures both useful for nostr relays and clients",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "NostrBasics",
      source_url: "https://github.com/roosoft/nostr_basics",
      homepage_url: "https://github.com/roosoft/nostr_basics",
      package: package(),
      docs: docs()
    ]
  end

  def package do
    [
      maintainers: ["Marc Lacoursière"],
      licenses: ["UNLICENCE"],
      links: %{"GitHub" => "https://github.com/roosoft/nostr_basics"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: docs_extras(),
      assets: "/guides/assets",
      source_ref: @version,
      source_url: "https://github.com/RooSoft/nostr_basics"
    ]
  end

  def docs_extras do
    [
      "README.md"
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
      {:ex_doc, "~> 0.29.1", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.4"},
      {:k256, "~> 0.0.7"},
      {:binary, "~> 0.0.5"},
      {:bech32, "~> 1.0"}
    ]
  end
end

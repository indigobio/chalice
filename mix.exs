defmodule Chalice.Mixfile do
  use Mix.Project

  def project do
    [app: :chalice,
     version: "0.1.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     package: package,
     name: "Chalice",
     description: """
     Useful Elixir code
     """]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ecto, "~> 2.0"},

     # dev only
     {:credo, "~> 0.4", only: [:dev, :test]},
     {:dogma, "~> 0.1", only: :dev},
     {:dialyxir, "~> 0.3.5", only: [:dev]}]
  end

  defp package do
    [files: ~w(lib mix.exs README.md)]
  end
end

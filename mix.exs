defmodule EctoTypesense.MixProject do
  use Mix.Project

  @moduledoc false
  @description "Index your ecto schemas into Typesense!"
  @source_url "https://github.com/sevensidedmarble/ecto_typesense"
  @version "0.9.0"

  def project do
    [
      app: :ecto_typesense,
      description: @description,
      version: @version,
      package: package(),
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application, do: [extra_applications: [:logger]]

  defp deps do
    [
      {:ex_check, "~> 0.14.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.29.0", only: :dev, runtime: false},
      {:credo, ">= 0.0.0", only: [:dev, :test]},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:mox, "~> 0.5", only: :test},
      {:mimic, "~> 1.7", only: :test},
      {:ecto, "~> 3.9"},
      {:httpoison, "~> 1.8.2"},
      {:jason, "~> 1.2"}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      extras: ["README.md"],
      source_url: @source_url,
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE),
      maintainers: ["sevensidedmarble"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end
end

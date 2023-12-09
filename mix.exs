defmodule GraphQL.Mixfile do
  use Mix.Project

  @version "0.4.0"

  @description "GraphQL Elixir implementation"
  @repo_url "https://github.com/graphql-elixir/graphql"

  def project do
    [
      app: :graphql,
      version: @version,
      elixir: "~> 1.15",
      description: @description,
      deps: deps(),
      package: package(),
      source_url: @repo_url,
      homepage_url: @repo_url,
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: true,
      name: "GraphQL",
      docs: [main: "GraphQL", logo: "logo.png", extras: ["README.md"]]
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:mix_test_watch, "~> 0.2", only: :dev},
      {:credo, "~> 1.7", only: [:test, :dev], runtime: false},

      # Doc dependencies
      {:earmark, "~> 1.4", only: :dev},
      {:ex_doc, "~> 0.30", only: :dev},
      {:dialyxir, "~> 1.4", only: [:dev]},
      {:poison, "~> 5.0", only: [:dev, :test]}
    ]
  end

  defp package do
    [
      maintainers: ["Josh Price", "James Sadler", "Mark Olson", "Aaron Weiker", "Sean Abrahams"],
      licenses: ["BSD"],
      links: %{"GitHub" => @repo_url},
      files: ~w(lib src/*.xrl src/*.yrl mix.exs *.md LICENSE)
    ]
  end
end

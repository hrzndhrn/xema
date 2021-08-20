defmodule Xema.Mixfile do
  use Mix.Project

  @source_url "https://github.com/hrzndhrn/xema"
  @version "0.14.0"

  def project do
    [
      app: :xema,
      version: @version,
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),

      # Coveralls
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        carp: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.travis": :test,
        "coveralls.html": :test,
        "gen.test_suite": :test
      ],

      # Dialyzer
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        plt_add_apps: [:decimal],
        plt_file: {:no_warn, "test/support/plts/dialyzer.plt"}
      ]
    ]
  end

  def application do
    [extra_applications: [:logger], env: [loader: Xema.NoLoader]]
  end

  defp deps do
    [
      {:benchee, "~> 1.0", only: :dev, runtime: false},
      {:conv_case, "~> 0.2.2"},
      {:cowboy, "~> 2.7.0", only: :test},
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:decimal, "~> 1.0 or ~> 2.0", optional: true},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:elixir_uuid, "~> 1.2", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:jason, "~> 1.1", only: [:dev, :test]},
      {:httpoison, "~> 1.8", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [carp: "test --seed 0 --max-failures 1 --trace"]
  end

  defp package do
    [
      description: "A schema validator inspired by JSON Schema.",
      maintainers: ["Marcus Kruse"],
      licenses: ["MIT"],
      files: [
        ".formatter.exs",
        "lib",
        "mix.exs",
        "README*",
        "LICENSE*",
        "docs/readme.md",
        "docs/usage.md",
        "docs/loader.md",
        "docs/unsupported.md"
      ],
      links: %{
        "Changelog" => "https://hexdocs.pm/xema/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        "CODE_OF_CONDUCT.md": [title: "Code of Conduct"],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"],
        "docs/usage.md": [],
        "docs/cast.md": [],
        "docs/loader.md": [],
        "docs/examples.md": [],
        "docs/unsupported.md": [],
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"],
      skip_undefined_reference_warnings_on: [
        "CHANGELOG.md"
      ]
    ]
  end
end

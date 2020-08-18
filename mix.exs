defmodule Xema.Mixfile do
  use Mix.Project

  def project do
    [
      app: :xema,
      version: "0.11.3",
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      source_url: "https://github.com/hrzndhrn/xema",
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

      # Docs
      docs: [
        extras: [
          "docs/readme.md",
          "docs/usage.md",
          "docs/cast.md",
          "docs/loader.md",
          "docs/examples.md",
          "docs/unsupported.md",
          "CHANGELOG.md"
        ],
        main: "readme"
      ],

      # Dialyzer
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        plt_add_apps: [:decimal],
        plt_file: {:no_warn, "test/support/plts/dialyzer.plt"}
      ]
    ]
  end

  defp description() do
    "A schema validator inspired by JSON Schema."
  end

  def application do
    [extra_applications: [:logger], env: [loader: Xema.NoLoader]]
  end

  defp deps do
    [
      {:benchee, "~> 1.0", only: :dev, runtime: false},
      {:conv_case, "~> 0.2.2"},
      {:cowboy, "== 2.7.0", only: :test},
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:decimal, "~> 1.7", optional: true},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:elixir_uuid, "~> 1.2", only: [:dev, :test]},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:jason, "~> 1.1", only: [:dev, :test]},
      {:httpoison, "== 1.6.2", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [carp: "test --seed 0 --max-failures 1 --trace"]
  end

  defp package do
    [
      maintainers: ["Marcus Kruse"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/hrzndhrn/xema"},
      files: [
        "lib",
        "mix.exs",
        "README*",
        "LICENSE*",
        "docs/readme.md",
        "docs/usage.md",
        "docs/loader.md",
        "docs/unsupported.md"
      ]
    ]
  end
end

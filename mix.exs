defmodule Xema.Mixfile do
  use Mix.Project

  def project do
    [
      app: :xema,
      version: "0.17.5",
      elixir: "~> 1.13",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      source_url: "https://github.com/hrzndhrn/xema",
      docs: docs(),
      aliases: aliases(),
      dialyzer: dialyzer(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: preferred_cli_env()
    ]
  end

  defp description() do
    "A schema validator inspired by JSON Schema."
  end

  def application do
    [extra_applications: [:logger], env: [loader: Xema.NoLoader]]
  end

  def preferred_cli_env do
    [
      carp: :test,
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.github": :test,
      "coveralls.html": :test,
      "gen.test_suite": :test
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [carp: "test --seed 0 --max-failures 1 --trace"]
  end

  def docs do
    [
      main: "readme",
      formatters: ["html"],
      extras: [
        "docs/readme.md",
        "docs/usage.md",
        "docs/cast.md",
        "docs/loader.md",
        "docs/examples.md",
        "docs/unsupported.md",
        "CHANGELOG.md"
      ],
      skip_undefined_reference_warnings_on: [
        "CHANGELOG.md"
      ]
    ]
  end

  def dialyzer do
    [
      ignore_warnings: ".dialyzer_ignore.exs",
      plt_add_apps: [:decimal],
      plt_file: {:no_warn, "test/support/plts/dialyzer.plt"}
    ]
  end

  defp deps do
    [
      {:conv_case, "~> 0.2.2"},
      # dev/test
      {:benchee, "~> 1.0", only: :dev, runtime: false},
      {:cowboy, "~> 2.12", only: :test},
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:decimal, "~> 1.0 or ~> 2.0", optional: true},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:elixir_uuid, "~> 1.2", only: [:dev, :test]},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:jason, "~> 1.1", only: [:dev, :test]},
      {:httpoison, "~> 2.2", only: :test}
    ]
  end

  defp package do
    [
      maintainers: ["Marcus Kruse"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/hrzndhrn/xema"},
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
      ]
    ]
  end
end

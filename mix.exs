defmodule Xema.Mixfile do
  use Mix.Project

  def project do
    [
      app: :xema,
      version: "0.7.0",
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      source_url: "https://github.com/hrzndhrn/xema",

      # Coveralls
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],

      # Docs
      docs: [
        extras: [
          "docs/readme.md",
          "docs/usage.md",
          "docs/loader.md",
          "docs/examples.md",
          "docs/unsupported.md"
        ],
        main: "readme"
      ],

      # Dialyzer
      dialyzer: [
        ignore_warnings: "dialyzer.ignore-warnings"
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
      {:benchee, "~> 0.14", only: :dev},
      {:benchee_json, "~> 0.6", only: :dev},
      {:benchee_html, "~> 0.6", only: :dev},
      {:cowboy, "~> 2.4", only: :test},
      {:credo, "~> 1.0", only: [:dev, :test]},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:inch_ex, "~> 2.0", only: [:dev, :test]},
      {:httpoison, "~> 1.2", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

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

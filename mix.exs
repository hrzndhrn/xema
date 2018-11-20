defmodule Xema.Mixfile do
  use Mix.Project

  def project do
    [
      app: :xema,
      version: "0.4.0",
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      source_url: "https://github.com/hrzndhrn/xema",
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      docs: [
        extras: ["XEMA_README.md", "USAGE.md", "UNSUPPORTED_FEATURES.md"],
        main: "xema_readme"
      ],
      dialyzer: [
        ignore_warnings: "dialyzer.ignore-warnings"
      ]
    ]
  end

  defp description() do
    "A schema validator inspired by JSON Schema."
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:cowboy, "~> 2.4", only: :test},
      {:credo, "~> 0.10", only: [:dev, :test]},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.9", only: :test},
      {:inch_ex, "~> 2.0.0-rc1", only: [:dev, :test]},
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
        "XEMA_README.md",
        "USAGE.md",
        "UNSUPPORTED_FEATURES.md"
      ]
    ]
  end

  defp aliases do
    [
      credo: ["credo --strict"],
      spec: &spec/1,
      check: &check/1,
      check_test: ["test", "credo", "spec"]
    ]
  end

  defp spec(_), do: Mix.shell().cmd("mix dialyzer", env: [{"MIX_ENV", "test"}])

  defp check(_),
    do: Mix.shell().cmd("mix check_test", env: [{"MIX_ENV", "test"}])
end

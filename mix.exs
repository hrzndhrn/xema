defmodule Xema.Mixfile do
  use Mix.Project

  def project do
    [
      app: :xema,
      version: "0.3.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
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
        extras: ["README.md"],
        main: "readme"
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
      {:cowboy, "~> 2.2", only: [:dev, :test]},
      {:credo, "~> 0.9.0-rc8", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
      {:excoveralls, "~> 0.8", only: :test},
      {:httpoison, "~> 1.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      maintainers: ["Marcus Kruse"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/hrzndhrn/xema"}
    ]
  end
end

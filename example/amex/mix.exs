defmodule Amex.MixProject do
  use Mix.Project

  def project do
    [
      app: :amex,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:elixir_uuid, "~> 1.2", only: [:dev, :test]},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:xema, path: "../.."}
    ]
  end
end

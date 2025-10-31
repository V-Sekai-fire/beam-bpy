defmodule BeamBpy.MixProject do
  use Mix.Project

  def project do
    [
      app: :beam_bpy_tests,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: :cover]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:mox, "~> 1.2.0", only: :test},
      {:ex_unit, "~> 1.14", only: :test}
    ]
  end

  defp aliases do
    [
      test: "test --no-start",
      "test.simple": "test test_simple.exs",
      "test.integration": "test test_integration.exs",
      "test.client": "test test_client.exs",
      "test.all": "test"
    ]
  end
end

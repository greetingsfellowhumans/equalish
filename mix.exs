defmodule Equalish.MixProject do
  use Mix.Project

  def project do
    [
      app: :equalish,
      version: "1.0.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      docs: docs(),
      description: description(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      cli: cli(),
      deps: deps()
    ]
  end

  defp cli() do
    [preferred_cli_env: ["test.watch": :test]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs() do
    [
      main: "readme",
      extras: [
        "README.md",
      ]
    ]
  end
  defp description() do
    "Guards and operators for floats that are *almost* equal. is_eq_ish(0.2, 0.200000001)"
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["greetingsfellowhumans"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/greetingsfellowhumans/weighted_random"}
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:mix_test_interactive, "~> 5.1", only: [:dev, :test], runtime: false}
    ]
  end
end

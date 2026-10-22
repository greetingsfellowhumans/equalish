defmodule Equalish.MixProject do
  use Mix.Project

  @version "1.0.2"
  @source_url "https://github.com/greetingsfellowhumans/equalish"

  def project do
    [
      app: :equalish,
      version: @version,
      source_url: @source_url,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      docs: docs(),
      description: description(),
      package: package(),
      cli: cli(),
      deps: deps()
    ]
  end

  defp cli() do
    [preferred_cli_env: ["test.watch": :test]]
  end

  defp docs() do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extras: [
        "README.md",
        "CHANGELOG.md"
      ]
    ]
  end

  defp description() do
    "solve floating point bugs. is_eq_ish(0.1 + 0.2, 0.3) => true"
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README*", "CHANGELOG*", "LICENSE*"],
      maintainers: ["greetingsfellowhumans"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md"
      }
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
      {:mix_test_interactive, "~> 5.1", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 1.1", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end

defmodule ZiglerPrecompiled.MixProject do
  use Mix.Project

  @version "0.1.2"
  @repo "https://github.com/dannote/zigler_precompiled"

  def project do
    [
      app: :zigler_precompiled,
      version: @version,
      elixir: "~> 1.14",
      description: "Download and use precompiled Zig NIFs safely with checksums",
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :inets, :ssl, :crypto, :public_key]
    ]
  end

  defp docs do
    [
      main: "ZiglerPrecompiled",
      extras: ["PRECOMPILATION_GUIDE.md", "CHANGELOG.md"],
      source_url: @repo,
      source_ref: "v#{@version}"
    ]
  end

  defp deps do
    [
      {:zigler, "~> 0.13 or ~> 0.14 or ~> 0.15", optional: true},
      {:castore, "~> 0.1 or ~> 1.0"},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:bypass, "~> 2.1", only: :test}
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Danila Poyarkov"],
      files: ~w(lib mix.exs README.md LICENSE CHANGELOG.md PRECOMPILATION_GUIDE.md),
      links: %{"GitHub" => @repo}
    }
  end
end

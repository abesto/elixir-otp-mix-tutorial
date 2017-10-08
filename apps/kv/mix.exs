defmodule KV.Mixfile do
  use Mix.Project

  def project do
    [
      app: :kv,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {KV, []}
    ]
  end

  defp deps do
    []
  end
end

defmodule Testapp.Mixfile do
  use Mix.Project

  def project do
    [app: :testapp,
     version: "0.1.0",
     build_path: "../../_build",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Testapp.Application, []}]
  end

  defp deps do
    [{:kick_web, in_umbrella: true}]
  end
end

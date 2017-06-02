defmodule Kick.Web.Mixfile do
  use Mix.Project

  def project do
    [app: :kick_web,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:kick_core, in_umbrella: true},
      {:plug, "~> 1.0"}
    ]
  end
end

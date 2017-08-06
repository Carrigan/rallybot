defmodule Rallybot.Mixfile do
  use Mix.Project

  def project() do
    [app: :rallybot,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application() do
    [
      applications: [:discord_ex],
      extra_applications: [:logger],
      mod: {Rallybot.Application, []}
    ]
  end

  defp deps() do
    [
      {:discord_ex, git: "https://github.com/tielur/discord_ex.git", branch: "update-deps"}
    ]
  end
end

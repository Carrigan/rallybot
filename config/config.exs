use Mix.Config

config :rallybot,
  discord_api_token: System.get_env("DISCORD_API_KEY")

config :porcelain, driver: Porcelain.Driver.Basic

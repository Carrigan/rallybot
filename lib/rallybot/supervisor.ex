defmodule Rallybot.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    token = Application.get_env(:rallybot, :discord_api_token)

    children = [
      worker(Rallybot, []),
      worker(DiscordEx.Client, [%{token: token, handler: Rallybot.EventHandler}])
    ]

    supervise(children, strategy: :one_for_one)
  end
end

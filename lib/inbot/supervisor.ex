defmodule Inbot.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    token = Application.get_env(:inbot, :discord_api_token)

    children = [
      worker(Inbot, []),
      worker(DiscordEx.Client, [%{token: token, handler: Inbot.EventHandler}])
    ]

    supervise(children, strategy: :one_for_one)
  end
end

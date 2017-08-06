defmodule Rallybot.Application do
  use Application

  def start(_type, _args) do
    Rallybot.Supervisor.start_link()
  end
end

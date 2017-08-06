defmodule Inbot.Application do
  use Application

  def start(_type, _args) do
    Inbot.Supervisor.start_link()
  end
end

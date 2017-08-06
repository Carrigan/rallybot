defmodule Inbot.EventHandler do
  alias DiscordEx.RestClient.Resources.Channel
  alias DiscordEx.Client.Helpers.MessageHelper

  def handle_event({:message_create, payload}, state) do
    spawn fn -> _handle_async(payload, state) end
    {:ok, state}
  end

  def handle_event({event, payload}, state), do: {:ok, state}

  # Ignore bots
  defp _handle_async(%{data: %{"author" => %{"bot" => true}}}, _), do: nil

  defp _handle_async(payload, state) do
    case MessageHelper.msg_command_parse(payload) do
      {nil, _} -> nil
      {cmd, msg} -> _process(cmd, msg, payload, state)
    end
  end

  defp _process("echo", msg, payload, state) do
    user_id = payload.data["author"]["id"]

    Channel.send_message(
      state[:rest_client],
      payload.data["channel_id"],
      %{content: "<@#{user_id}> #{msg}"}
    )
  end

  defp _process(_, _, _, _), do: nil
end

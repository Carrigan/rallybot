defmodule Inbot.EventHandler do
  @command_string "$"

  alias DiscordEx.RestClient.Resources.Channel
  alias DiscordEx.Client.Helpers.MessageHelper

  def handle_event({:message_create, payload}, state) do
    spawn fn -> _handle_async(payload, state) end
    {:ok, state}
  end

  def handle_event({_, _}, state), do: {:ok, state}

  # Ignore bots
  defp _handle_async(%{data: %{"author" => %{"bot" => true}}}, _), do: nil

  defp _handle_async(payload, state) do
    case MessageHelper.msg_command_parse(payload, @command_string) do
      {nil, _} -> nil
      {cmd, msg} -> _process(cmd, msg, payload, state)
    end
  end

  defp _process("echo", msg, payload, state) do
    user_id = payload.data["author"]["id"]
    respond("<@#{user_id}> #{msg}", payload, state)
  end

  defp _process("status", _, payload, state) do
    response = Inbot.status
    respond(response.text, payload, state)
  end

  defp _process("group", msg, payload, state) do
    tokens = String.split(msg)
    process_group_create(tokens, payload, state)
  end

  defp _process("in", group, payload, state) do
    response = Inbot.set_in(group, payload.data["author"])
    respond(response.text, payload, state)
  end

  defp _process("out", group, payload, state) do
    response = Inbot.clear_in(group, payload.data["author"])
    respond(response.text, payload, state)
  end

  defp _process(_, _, _, _), do: nil

  def process_group_create([name, trigger], payload, state) do
    _process_group_create(Integer.parse(trigger, 10), name, payload, state)
  end

  def process_group_create(_, payload, state) do
    respond("#{@command_string}group <name> <trigger count>", payload, state)
  end

  def _process_group_create({trigger, _}, name, payload, state) do
    response = Inbot.create_group(name, trigger)
    respond(response.text, payload, state)
  end

  def _process_group_create(:error, _, payload, state) do
    respond("#{@command_string}group <name> <trigger count>", payload, state)
  end

  defp respond(message, payload, state) do
    Channel.send_message(
      state[:rest_client],
      payload.data["channel_id"],
      %{content: message}
    )
  end
end

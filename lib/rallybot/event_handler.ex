defmodule Rallybot.EventHandler do
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

  defp _process("help", _, payload, state) do
    help_string = """
      Warning: this is still early alpha access (with right around how much effort has been put into H1Z1). Please only take happy paths or you will crash the bot. Names should not have spaces and do not $in or $out to nonexistant groups!

      Available commands are:
      **$status** Lets you know what groups are around and who is waiting in them.
      **$group <name> <trigger>** Creates or updates a group to go off with count <trigger>.
      **$in <name>** Add yourself to a group's in-list. If the threshold is met, everyone will get notified.
      **$out <name>** Remove yourself from a group's in-list."
    """

    respond(help_string, payload, state)
  end

  defp _process("status", _, payload, state) do
    response = Rallybot.status
    respond(response, payload, state)
  end

  defp _process("group", msg, payload, state) do
    tokens = String.split(msg)
    process_group_create(tokens, payload, state)
  end

  defp _process("in", group, payload, state) do
    response = Rallybot.set_in(group, payload.data["author"])
    respond(response, payload, state)
  end

  defp _process("out", group, payload, state) do
    response = Rallybot.clear_in(group, payload.data["author"])
    respond(response, payload, state)
  end

  defp _process(_, _, _, _), do: nil

  def process_group_create([name, trigger], payload, state) do
    _process_group_create(Integer.parse(trigger, 10), name, payload, state)
  end

  def process_group_create(_, payload, state) do
    respond("#{@command_string}group <name> <trigger count>", payload, state)
  end

  def _process_group_create({trigger, _}, name, payload, state) do
    response = Rallybot.create_group(name, trigger)
    respond(response, payload, state)
  end

  def _process_group_create(:error, _, payload, state) do
    respond("#{@command_string}group <name> <trigger count>", payload, state)
  end

  defp respond(%Rallybot.Response{text: text, alert: alerts}, payload, state) when alerts == [] do
    respond(text, payload, state)
  end

  defp respond(%Rallybot.Response{alert: alerts}, payload, state) do
    user_mentions = Enum.map(alerts, fn user_id -> "<@#{user_id}>" end) |> Enum.join()
    respond("[#{user_mentions}] -- get on its time to rally!", payload, state)
  end

  defp respond(message, payload, state) do
    Channel.send_message(
      state[:rest_client],
      payload.data["channel_id"],
      %{content: message}
    )
  end
end

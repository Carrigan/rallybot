defmodule Rallybot do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def status() do
    GenServer.call(__MODULE__, :status)
  end

  def create_group(group_name, trigger) do
    GenServer.call(__MODULE__, {:create, group_name, trigger})
  end

  def set_in(group_name, user) do
    GenServer.call(__MODULE__, {:set, group_name, user})
  end

  def clear_in(group_name, user) do
    GenServer.call(__MODULE__, {:clear, group_name, user})
  end

  ## Private Calls

  def init(_) do
    {:ok, %{}}
  end

  def handle_call(:status, _from, state) do
    {:reply, %Rallybot.Response{text: Rallybot.Formatter.format_status(state)}, state}
  end

  def handle_call({:create, group_name, trigger}, _from, state) do
    group = Map.get(state, group_name, %Rallybot.Group{}) |> Map.put(:trigger, trigger)
    next_state = Map.put(state, group_name, group)

    response = %Rallybot.Response{
      text: "Group updated.",
      alert: Rallybot.Group.generate_alerts(group)
    }

    {:reply, response, next_state}
  end

  def handle_call({:set, group_name, user}, _from, state) do
    next_state = Map.update!(state, group_name, fn group -> Rallybot.Group.add(group, user) end)

    # TODO: Handle errors if group DNE
    response = %Rallybot.Response{
      text: "Added to #{group_name}",
      alert: Rallybot.Group.generate_alerts(Map.get(next_state, group_name))
    }

    {:reply, response, next_state}
  end

  def handle_call({:clear, group_name, user}, _from, state) do
    # TODO: Handle errors if group DNE
    next_state = Map.update!(state, group_name, fn group -> Rallybot.Group.clear(group, user) end)
    {:reply, %Rallybot.Response{text: "Removed from #{group_name}."}, next_state}
  end
end

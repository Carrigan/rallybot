defmodule Inbot do
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
    {:reply, %Inbot.Response{text: "#{inspect state}"}, state}
  end

  def handle_call({:create, group_name, trigger}, _from, state) do
    group = Map.get(state, group_name, %Inbot.Group{}) |> Map.put(:trigger, trigger)
    next_state = Map.put(state, group_name, group)

    {:reply, %Inbot.Response{text: "Group created."}, next_state}
  end
end

defmodule Rallybot.Group do
  defstruct trigger: 0, users: []

  def format(%Rallybot.Group{trigger: trigger, users: []}) do
    "Requires #{trigger}, has none."
  end

  def format(%Rallybot.Group{trigger: trigger, users: users}) do
    users_string = Enum.map(users, fn user -> user["username"] end) |> Enum.join()
    "Requires #{trigger}, has #{users_string}."
  end

  def add(%Rallybot.Group{trigger: trigger, users: users} = group, user) do
    case Enum.find(users, fn u -> user["id"] == u["id"] end) do
      nil -> %Rallybot.Group{trigger: trigger, users: [user | users]}
      _ -> group
    end
  end

  def clear(%Rallybot.Group{trigger: trigger, users: users}, user) do
    %Rallybot.Group{trigger: trigger, users: Enum.reject(users, fn u -> u["id"] == user["id"] end)}
  end

  def generate_alerts(%Rallybot.Group{trigger: trigger, users: users}) do
    case Enum.count(users) >= trigger do
      true -> Enum.map(users, fn user -> user["id"] end)
      _ -> []
    end
  end
end

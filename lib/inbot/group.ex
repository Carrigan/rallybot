defmodule Inbot.Group do
  defstruct trigger: 0, users: []

  def format(%Inbot.Group{trigger: trigger, users: []}) do
    "Requires #{trigger}, has none."
  end

  def format(%Inbot.Group{trigger: trigger, users: users}) do
    users_string = Enum.map(users, fn user -> user["username"] end) |> Enum.join()
    "Requires #{trigger}, has #{users_string}."
  end

  def add(%Inbot.Group{trigger: trigger, users: users} = group, user) do
    case Enum.find(users, fn u -> user["id"] == u["id"] end) do
      nil -> %Inbot.Group{trigger: trigger, users: [user | users]}
      _ -> group
    end
  end

  def clear(%Inbot.Group{trigger: trigger, users: users}, user) do
    %Inbot.Group{trigger: trigger, users: Enum.reject(users, fn u -> u["id"] == user["id"] end)}
  end

  def is_triggered?(%Inbot.Group{trigger: trigger, users: users}) do
    Enum.count(users) >= trigger
  end
end

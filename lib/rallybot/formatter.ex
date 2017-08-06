defmodule Rallybot.Formatter do
  def format_status(status) when status == %{} do
    "No groups found."
  end

  def format_status(status) do
    Enum.map(status, &format_entry/1) |> Enum.join()
  end

  def format_entry({group_name, group_struct}) do
    "**#{group_name}:** #{Rallybot.Group.format(group_struct)}\n"
  end
end

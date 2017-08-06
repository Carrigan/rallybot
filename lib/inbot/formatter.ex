defmodule Inbot.Formatter do
  def format_status(status) when status == %{} do
    "No groups found."
  end

  def format_status(status) do
    Enum.map(status, &format_entry/1) |> Enum.join()
  end

  def format_entry({group_name, group_struct}) do
    "**#{group_name}:** #{Inbot.Group.format(group_struct)}\n"
  end
end

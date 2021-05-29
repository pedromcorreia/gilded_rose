defmodule Mock do
  @moduledoc """
  Module for mock data and help in tests.
  """
  def find_item_by_day(day) when day <= 1000 and day >= 0 do
    File.read!("gilded_rose_data.json")
    |> Poison.decode!()
    |> Enum.find(fn x -> x["day"] == day end)
    |> Map.get("product")
    |> string_key_to_atom_map
  end

  defp string_key_to_atom_map(list_string_map) do
    Enum.map(list_string_map, fn string_map ->
      struct(
        GildedRose.Item,
        for({key, val} <- string_map, into: %{}, do: {String.to_atom(key), val})
      )
    end)
  end
end

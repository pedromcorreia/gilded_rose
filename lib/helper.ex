defmodule Helper do
  @moduledoc """
  The module for export data and help in tests.
  """
  def export_existing_data do
    gilded_rose_leeroy = GildedRose.new()

    "gilded_rose_data.json"
    |> File.open!([:write, :utf8])
    |> IO.write(encode_gilded_rose_data(gilded_rose_leeroy))
  end

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

  defp encode_gilded_rose_data(gilded_rose_leeroy) do
    Enum.map(0..1000, fn day ->
      product =
        gilded_rose_leeroy
        |> GildedRose.items()
        |> Enum.map(&Map.from_struct/1)

      encode_day = %{day: day, product: product}

      GildedRose.update_quality(gilded_rose_leeroy, :leeroy)
      encode_day
    end)
    |> Poison.encode!()
  end
end

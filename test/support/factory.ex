defmodule Support.Factory do
  @moduledoc """
  Module for mock data and help in tests.
  """
  @dexterity_vest "+5 Dexterity Vest"
  @aged_brie "Aged Brie"
  @elixir "Elixir of the Mongoose"
  @sulfuras "Sulfuras, Hand of Ragnaros"
  @backstage "Backstage passes to a TAFKAL80ETC concert"
  @conjured "Conjured Mana Cake"

  def item(name, opts \\ %{}) do
    name
    |> default_values()
    |> Map.merge(opts)
    |> init_schema()
  end

  def default_values(:dexterity_vest) do
    %{name: @dexterity_vest, quality: 20, sell_in: -10}
  end

  def default_values(:sulfuras) do
    %{name: @sulfuras, quality: 80, sell_in: 0}
  end

  def default_values(:aged_brie) do
    %{name: @aged_brie, quality: 0, sell_in: 0}
  end

  defp init_schema(%{name: name, quality: quality, sell_in: sell_in}) do
    %GildedRose.Item{name: name, quality: quality, sell_in: sell_in}
  end
end

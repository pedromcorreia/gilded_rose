defmodule Support.Factory do
  @moduledoc """
  Module for mock data and help in tests.
  """

  alias GildedRose.Item

  @dexterity_vest "+5 Dexterity Vest"
  @aged_brie "Aged Brie"
  @elixir "Elixir of the Mongoose"
  @sulfuras "Sulfuras, Hand of Ragnaros"
  @backstage "Backstage passes to a TAFKAL80ETC concert"
  @conjured "Conjured Mana Cake"

  @spec item(atom(), map()) :: %Item{}
  def item(name, opts \\ %{}) when is_atom(name) do
    name
    |> default_values()
    |> Map.merge(opts)
    |> init_schema()
  end

  @spec default_values(atom()) :: map()
  def default_values(:dexterity_vest) do
    %{name: @dexterity_vest, quality: 20, sell_in: -10}
  end

  def default_values(:elixir) do
    %{name: @elixir, quality: 20, sell_in: -10}
  end

  def default_values(:sulfuras) do
    %{name: @sulfuras, quality: 80, sell_in: 0}
  end

  def default_values(:aged_brie) do
    %{name: @aged_brie, quality: 0, sell_in: 0}
  end

  def default_values(:backstage) do
    %{name: @backstage, quality: 20, sell_in: 11}
  end

  def default_values(:conjured) do
    %{name: @conjured, quality: 0, sell_in: -3}
  end

  @spec init_schema(map()) :: %Item{}
  defp init_schema(%{name: name, quality: quality, sell_in: sell_in}) do
    %Item{name: name, quality: quality, sell_in: sell_in}
  end
end

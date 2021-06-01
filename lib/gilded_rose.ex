defmodule GildedRose do
  @moduledoc """
  GildedRose module, responsible for storing item data and their status.
  """

  use Agent
  alias GildedRose.Item

  @dexterity_vest "+5 Dexterity Vest"
  @aged_brie "Aged Brie"
  @elixir "Elixir of the Mongoose"
  @sulfuras "Sulfuras, Hand of Ragnaros"
  @backstage "Backstage passes to a TAFKAL80ETC concert"
  @conjured "Conjured Mana Cake"
  @legendary_items [@sulfuras]
  @legendary_values %{quality: 80, sell_in: 0}

  @doc """
  Init new agent with default items and values.

  ## Examples
      iex> GildedRose.new()
  """
  @spec new() :: pid()
  def new() do
    {:ok, agent} =
      Agent.start_link(fn ->
        [
          Item.new(@dexterity_vest, 10, 20),
          Item.new(@aged_brie, 2, 0),
          Item.new(@elixir, 5, 7),
          Item.new(@sulfuras, 0, 80),
          Item.new(@backstage, 15, 20),
          Item.new(@conjured, 3, 6)
        ]
      end)

    agent
  end

  @doc """
  Return items list.
  Returns `[%GildedRose.Item{}]`.

  ## Examples
      iex> agent = GildedRose.new()
      iex> GildedRose.items(agent)
      [
        %GildedRose.Item{name: "+5 Dexterity Vest", quality: 20, sell_in: 10},
        %GildedRose.Item{name: "Aged Brie", quality: 0, sell_in: 2},
        %GildedRose.Item{name: "Elixir of the Mongoose", quality: 7, sell_in: 5},
        %GildedRose.Item{name: "Sulfuras, Hand of Ragnaros", quality: 80, sell_in: 0},
        %GildedRose.Item{name: "Backstage passes to a TAFKAL80ETC concert", quality: 20, sell_in: 15},
        %GildedRose.Item{name: "Conjured Mana Cake", quality: 6, sell_in: 3}
      ]
  """
  @spec items(pid()) :: list(%Item{})
  def items(agent), do: Agent.get(agent, & &1)

  @doc """
  Update all items in process id with their respective rules.
  Returns `:ok`.

  ## Examples
      iex> agent = GildedRose.new()
      iex> GildedRose.update_quality(agent)
      :ok
  """
  @spec update_quality(pid()) :: :ok | :error
  def update_quality(agent) when is_pid(agent) do
    case is_list(update_quality_items(agent)) do
      true ->
        :ok
    end
  end

  @spec update_quality_items(pid()) :: list(%Item{})
  defp update_quality_items(agent) do
    {items, _} =
      items(agent)
      |> Enum.map_reduce(0, fn item, index ->
        with item = %Item{} <- update_item(item),
             :ok <- update(agent, index, item) do
          {item, index + 1}
        end
      end)

    items
  end

  @spec update(pid(), number(), %Item{}) :: :ok
  defp update(agent, index, item) when is_pid(agent) do
    Agent.update(agent, &List.replace_at(&1, index, item))
  end

  @doc """
  Update Item struct with specific rule.
  Returns `%Item{}`.

  ## Examples
      iex> GildedRose.update_item(%GildedRose.Item{name: "Elixir of the Mongoose", quality: 1, sell_in: 1})
      %GildedRose.Item{name: "Elixir of the Mongoose", quality: 0, sell_in: 0}
  """
  @spec update_item(%Item{}) :: %Item{}
  def update_item(%Item{name: @backstage, sell_in: sell_in} = item) when sell_in <= 0 do
    %{item | quality: 0} |> decrease_sell_in
  end

  def update_item(%Item{name: @backstage, sell_in: sell_in} = item) when sell_in <= 5 do
    item |> increase_quality(3) |> decrease_sell_in
  end

  def update_item(%Item{name: @backstage, sell_in: sell_in} = item) when sell_in <= 10 do
    item |> increase_quality(2) |> decrease_sell_in
  end

  def update_item(%Item{name: @backstage, sell_in: sell_in} = item) when sell_in > 0 do
    item |> increase_quality(1) |> decrease_sell_in
  end

  def update_item(%Item{name: name} = item) when name in @legendary_items,
    do: %{item | quality: @legendary_values.quality}

  def update_item(%Item{name: @aged_brie, sell_in: sell_in} = item) when sell_in > 0 do
    item |> increase_quality(1) |> decrease_sell_in
  end

  def update_item(%Item{name: @aged_brie} = item) do
    item |> increase_quality(2) |> decrease_sell_in
  end

  def update_item(%Item{quality: quality} = item) when quality < 1 do
    item |> decrease_sell_in
  end

  def update_item(%Item{sell_in: sell_in, name: @conjured} = item) when sell_in >= 0 do
    item |> increase_quality(-2) |> decrease_sell_in
  end

  def update_item(%Item{sell_in: sell_in, name: @conjured} = item) when sell_in < 0 do
    item |> increase_quality(-4) |> decrease_sell_in
  end

  def update_item(%Item{sell_in: sell_in, name: name} = item)
      when sell_in <= 0 and name != @conjured do
    item |> increase_quality(-2) |> decrease_sell_in
  end

  def update_item(%Item{} = item) do
    item |> increase_quality(-1) |> decrease_sell_in
  end

  @spec increase_quality(%Item{}, number()) :: %Item{}
  defp increase_quality(%Item{quality: quality} = item, amount) do
    quality = min(quality + amount, 50)
    %{item | quality: quality}
  end

  @spec decrease_sell_in(%Item{}) :: %Item{}
  defp decrease_sell_in(%Item{sell_in: sell_in} = item) do
    %{item | sell_in: sell_in - 1}
  end
end

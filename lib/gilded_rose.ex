defmodule GildedRose do
  use Agent
  alias GildedRose.Item

  @dexterity_vest "+5 Dexterity Vest"
  @aged_brie "Aged Brie"
  @elixir "Elixir of the Mongoose"
  @sulfuras "Sulfuras, Hand of Ragnaros"
  @backstage "Backstage passes to a TAFKAL80ETC concert"
  @conjured "Conjured Mana Cake"

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

  def update_quality(agent) when is_pid(agent) do
    Enum.each(0..agent_length(agent), fn index ->
      with item = %Item{} <- get_and_update(agent, index),
           :ok <- update(agent, index, item) do
        :ok
      end
    end)
  end

  defp get(agent, index) when is_pid(agent) do
    Agent.get(agent, &Enum.at(&1, index))
  end

  defp agent_length(agent) do
    Agent.get(agent, &length/1) - 1
  end

  defp update(agent, index, item) when is_pid(agent) do
    Agent.update(agent, &List.replace_at(&1, index, item))
  end

  defp get_and_update(agent, index) when is_pid(agent) do
    agent
    |> get(index)
    |> update_item()
  end

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

  def update_item(%Item{name: @sulfuras} = item), do: %{item | quality: 80}

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

  defp increase_quality(%Item{quality: quality} = item, amount) do
    quality = min(quality + amount, 50)
    %{item | quality: quality}
  end

  defp decrease_sell_in(%Item{sell_in: sell_in} = item) do
    %{item | sell_in: sell_in - 1}
  end
end

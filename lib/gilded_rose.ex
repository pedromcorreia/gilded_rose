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

  def items(agent), do: Agent.get(agent, & &1)

  def product(agent, arg), do: Enum.find(items(agent), &(&1.name == arg))

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

  def update_item(%Item{name: @sulfuras} = item) do
    %{item | quality: 80}
  end

  def update_item(%Item{quality: quality} = item) when quality >= 50 do
    item |> decrease_sell_in
  end

  def update_item(%Item{name: @aged_brie, sell_in: sell_in} = item) when sell_in > 0 do
    item |> increase_quality(1) |> decrease_sell_in
  end

  def update_item(%Item{name: @aged_brie} = item) do
    item |> increase_quality(2) |> decrease_sell_in
  end

  def update_item(%Item{quality: quality} = item) when quality < 1 do
    item |> decrease_sell_in
  end

  def update_item(%Item{sell_in: sell_in, name: name} = item)
      when sell_in <= 0 and name != @conjured do
    item |> increase_quality(-2) |> decrease_sell_in
  end

  def update_item(%Item{sell_in: sell_in, name: @conjured} = item) when sell_in == 0 do
    item |> increase_quality(-2) |> decrease_sell_in
  end

  def update_item(%Item{} = item) do
    item |> increase_quality(-1) |> decrease_sell_in
  end

  defp increase_quality(%Item{quality: quality} = item, amount) do
    %{item | quality: quality + amount}
  end

  defp decrease_sell_in(%Item{sell_in: sell_in} = item) do
    %{item | sell_in: sell_in - 1}
  end

  def update_quality(agent) do
    for i <- 0..(Agent.get(agent, &length/1) - 1) do
      item = Agent.get(agent, &Enum.at(&1, i))
      item = update_item(item)

      Agent.update(agent, &List.replace_at(&1, i, item))
    end

    :ok
  end

  # keep while refactoring
  def update_quality(agent, :leeroy) do
    for i <- 0..(Agent.get(agent, &length/1) - 1) do
      item = Agent.get(agent, &Enum.at(&1, i))

      item =
        cond do
          item.name != "Aged Brie" && item.name != "Backstage passes to a TAFKAL80ETC concert" ->
            if item.quality > 0 do
              if item.name != "Sulfuras, Hand of Ragnaros" do
                %{item | quality: item.quality - 1}
              else
                item
              end
            else
              item
            end

          true ->
            cond do
              item.quality < 50 ->
                item = %{item | quality: item.quality + 1}

                cond do
                  item.name == "Backstage passes to a TAFKAL80ETC concert" ->
                    item =
                      cond do
                        item.sell_in < 11 ->
                          cond do
                            item.quality < 50 ->
                              %{item | quality: item.quality + 1}

                            true ->
                              item
                          end

                        true ->
                          item
                      end

                    cond do
                      item.sell_in < 6 ->
                        cond do
                          item.quality < 50 ->
                            %{item | quality: item.quality + 1}

                          true ->
                            item
                        end

                      true ->
                        item
                    end

                  true ->
                    item
                end

              true ->
                item
            end
        end

      item =
        cond do
          item.name != "Sulfuras, Hand of Ragnaros" ->
            %{item | sell_in: item.sell_in - 1}

          true ->
            item
        end

      item =
        cond do
          item.sell_in < 0 ->
            cond do
              item.name != "Aged Brie" ->
                cond do
                  item.name != "Backstage passes to a TAFKAL80ETC concert" ->
                    cond do
                      item.quality > 0 ->
                        cond do
                          item.name != "Sulfuras, Hand of Ragnaros" ->
                            %{item | quality: item.quality - 1}

                          true ->
                            item
                        end

                      true ->
                        item
                    end

                  true ->
                    %{item | quality: item.quality - item.quality}
                end

              true ->
                cond do
                  item.quality < 50 ->
                    %{item | quality: item.quality + 1}

                  true ->
                    item
                end
            end

          true ->
            item
        end

      Agent.update(agent, &List.replace_at(&1, i, item))
    end

    :ok
  end
end

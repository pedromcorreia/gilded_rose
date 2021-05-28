defmodule GildedRose do
  use Agent
  alias GildedRose.Item

  def new() do
    {:ok, agent} =
      Agent.start_link(fn ->
        [
          Item.new("+5 Dexterity Vest", 10, 20),
          Item.new("Aged Brie", 2, 0),
          Item.new("Elixir of the Mongoose", 5, 7),
          Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
          Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
          Item.new("Conjured Mana Cake", 3, 6)
        ]
      end)

    agent
  end

  def items(agent), do: Agent.get(agent, & &1)

  def product(agent, arg), do: Enum.find(items(agent), &(&1.name == arg))

  def update_quality(agent) do
    for i <- 0..(Agent.get(agent, &length/1) - 1) do
      item = Agent.get(agent, &Enum.at(&1, i))
      item = update_item(item)

      Agent.update(agent, &List.replace_at(&1, i, item))
    end

    :ok
  end

  def update_item(
        %GildedRose.Item{
          name: "Backstage passes to a TAFKAL80ETC concert",
          sell_in: sell_in
        } = item
      )
      when sell_in <= 5 and sell_in > 0 do
    increase_quality(item, 3)
  end

  def update_item(
        %GildedRose.Item{
          name: "Backstage passes to a TAFKAL80ETC concert",
          sell_in: sell_in
        } = item
      )
      when sell_in <= 10 and sell_in > 5 do
    increase_quality(item, 2)
  end

  def update_item(
        %GildedRose.Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: sell_in} =
          item
      )
      when sell_in > 0 do
    increase_quality(item, 1)
  end

  def update_item(
        %GildedRose.Item{
          name: "Backstage passes to a TAFKAL80ETC concert",
          quality: 0,
          sell_in: sell_in
        } = item
      ) do
    %{item | sell_in: sell_in - 1}
  end

  def update_item(%GildedRose.Item{name: "Backstage passes to a TAFKAL80ETC concert"} = item) do
    increase_quality(item, -1)
  end

  def update_item(%GildedRose.Item{name: "Sulfuras, Hand of Ragnaros"} = item) do
    item
  end

  def update_item(%GildedRose.Item{quality: quality, sell_in: sell_in} = item)
      when quality >= 50 do
    %{item | sell_in: sell_in - 1}
  end

  def update_item(%GildedRose.Item{name: "Aged Brie"} = item) do
    increase_quality(item, 1)
  end

  def update_item(%GildedRose.Item{quality: quality, sell_in: sell_in} = item)
      when quality < 1 do
    %{item | sell_in: sell_in - 1}
  end

  def update_item(%GildedRose.Item{sell_in: sell_in, name: name} = item)
      when sell_in <= 0 and name != "Conjured Mana Cake" do
    increase_quality(item, -2)
  end

  def update_item(%GildedRose.Item{} = item) do
    increase_quality(item, -1)
  end

  def increase_quality(%GildedRose.Item{quality: quality, sell_in: sell_in} = item, amount) do
    %{item | quality: quality + amount, sell_in: sell_in - 1}
  end

  # keep while refactoring
  def update_quality(agent) do
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

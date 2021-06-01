defmodule GildedRoseTest do
  use ExUnit.Case
  doctest GildedRose
  import Support.Factory

  describe "new/0" do
    test "init a process id" do
      assert is_pid(GildedRose.new())
    end
  end

  describe "update_item/1" do
    test "interface specification" do
      gilded_rose = GildedRose.new()
      [%GildedRose.Item{} | _] = Agent.get(gilded_rose, & &1)
      assert :ok == GildedRose.update_quality(gilded_rose)
    end
  end

  describe "items/1" do
    test "returns Items list" do
      gilded_rose = GildedRose.new()
      assert :ok == GildedRose.update_quality(gilded_rose)

      assert GildedRose.items(gilded_rose) == [
               %GildedRose.Item{name: "+5 Dexterity Vest", quality: 19, sell_in: 9},
               %GildedRose.Item{name: "Aged Brie", quality: 1, sell_in: 1},
               %GildedRose.Item{name: "Elixir of the Mongoose", quality: 6, sell_in: 4},
               %GildedRose.Item{name: "Sulfuras, Hand of Ragnaros", quality: 80, sell_in: 0},
               %GildedRose.Item{
                 name: "Backstage passes to a TAFKAL80ETC concert",
                 quality: 21,
                 sell_in: 14
               },
               %GildedRose.Item{name: "Conjured Mana Cake", quality: 4, sell_in: 2}
             ]
    end
  end

  describe "update_quality/1 for normal items" do
    test "if the sell_in days is less than 1, degrades twice fast" do
      dexterity = item(:dexterity_vest)
      assert GildedRose.update_item(dexterity).quality == 18
      elixir = item(:elixir)
      assert GildedRose.update_item(elixir).quality == 18
    end

    test "degrade quality when sell_in is more than 0" do
      elixir = item(:elixir, %{quality: 10, sell_in: 1})
      assert GildedRose.update_item(elixir).quality == 9
    end

    test "quality is never negative" do
      dexterity = item(:dexterity_vest, %{quality: 0})
      assert GildedRose.update_item(dexterity).quality == 0
      elixir = item(:elixir, %{quality: 0})
      assert GildedRose.update_item(elixir).quality == 0
    end
  end

  describe "update_quality/1 for Aged Brie" do
    test "increase quality when gets old" do
      aged_brie = item(:aged_brie, %{sell_in: 2})
      assert GildedRose.update_item(aged_brie).quality == 1
    end

    test "increase quality by two when sell_in expired" do
      aged_brie = item(:aged_brie)
      assert GildedRose.update_item(aged_brie).quality == 2
    end

    test "quality never more than 50" do
      aged_brie = item(:aged_brie, %{quality: 50})
      assert GildedRose.update_item(aged_brie).quality == 50
    end
  end

  describe "update_quality/1 for Legendary items" do
    test "when Sultufas sell_in is always 0" do
      sulfuras = item(:sulfuras)
      for _ <- 1..100, do: assert(GildedRose.update_item(sulfuras).sell_in == 0)
    end

    test "when Sultufas quality is always 80" do
      sulfuras = item(:sulfuras)
      for _ <- 1..100, do: assert(GildedRose.update_item(sulfuras).quality == 80)
    end
  end

  describe "update_item/1 for Backstage" do
    test "quality after concern drops to 0" do
      backstage = item(:backstage, %{quality: 100, sell_in: -2})
      assert GildedRose.update_item(backstage).quality == 0
    end

    test "when there is more than 10 days increase quality in 1" do
      backstage = item(:backstage)
      assert GildedRose.update_item(backstage).quality == 21
    end

    test "when sell_in is beteween 10 and 6, increase quality in 2" do
      backstage = item(:backstage, %{sell_in: 6})
      assert GildedRose.update_item(backstage).quality == 22
    end

    test "when there is less than 5 days increase quality in 3" do
      backstage = item(:backstage, %{sell_in: 2})
      assert GildedRose.update_item(backstage).quality == 23
    end
  end

  describe "update_quality/1 for Conjured" do
    test "never degrade less than 0" do
      conjured = item(:conjured)
      assert GildedRose.update_item(conjured).quality == 0
    end

    test "degrade quality by 2 when sell_in is more than 0" do
      conjured = item(:conjured, %{quality: 10, sell_in: 0})
      assert GildedRose.update_item(conjured).quality == 8
    end

    test "degrade quality by 4 when sell_in is more than 0" do
      conjured = item(:conjured, %{quality: 10, sell_in: -1})
      assert GildedRose.update_item(conjured).quality == 6
    end
  end
end

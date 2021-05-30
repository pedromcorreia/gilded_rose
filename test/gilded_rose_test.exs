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

    test "ensure that after 1000 days both functions return same value" do
      gilded_rose = GildedRose.new()

      for day <- 1..1000 do
        GildedRose.update_quality(gilded_rose)
        assert Agent.get(gilded_rose, & &1) == Mock.find_item_by_day(day)
      end
    end
  end

  describe "update_quality/1 for generic items" do
    test "if the sell_in days is less than zero, degrades twice fast" do
      dexterity = item(:dexterity_vest)
      assert GildedRose.update_item(dexterity).quality == 18
      elixir = item(:elixir)
      assert GildedRose.update_item(elixir).quality == 18
    end

    test "quality is never negative" do
      dexterity = item(:dexterity_vest, %{quality: 0})
      assert GildedRose.update_item(dexterity).quality == 0
      elixir = item(:elixir, %{quality: 0})
      assert GildedRose.update_item(elixir).quality == 0
    end
  end

  describe "update_quality/1 for Aged Brie" do
    test "must increase quality when gets old" do
      aged_brie = item(:aged_brie, %{sell_in: 2})
      assert GildedRose.update_item(aged_brie).quality == 1
    end

    test "must increase quality by two when sell_in expired" do
      aged_brie = item(:aged_brie)
      assert GildedRose.update_item(aged_brie).quality == 2
    end

    test "quality never more than 50" do
      aged_brie = item(:aged_brie, %{quality: 50})
      assert GildedRose.update_item(aged_brie).quality == 50
    end
  end

  describe "update_quality/1 for Sulfuras" do
    test "Sultufas sell_in always is always 0" do
      sulfuras = item(:sulfuras)
      for _ <- 1..100, do: assert(GildedRose.update_item(sulfuras).sell_in == 0)
    end

    test "Sultufas quality is always 80" do
      sulfuras = item(:sulfuras)
      for _ <- 1..100, do: assert(GildedRose.update_item(sulfuras).quality == 80)
    end
  end

  describe "update_item/1 for Backstage" do
    test "Backstage passes to a TAFKAL80ETC concert when there is more than 10 days increase quality in 1" do
      backstage = item(:backstage)
      assert GildedRose.update_item(backstage).quality == 21
    end

    test "Backstage passes to a TAFKAL80ETC concert when sell_in is beteween 10 and 6, increase quality in 2" do
      backstage = item(:backstage, %{sell_in: 6})
      assert GildedRose.update_item(backstage).quality == 22
    end

    test "Backstage passes to a TAFKAL80ETC concert when there is less than 5 days increase quality in 3" do
      backstage = item(:backstage, %{sell_in: 2})
      assert GildedRose.update_item(backstage).quality == 23
    end
  end

  describe "update_quality/1 for Conjured" do
    test "never degrade less than 0" do
      conjured = item(:conjured)
      assert GildedRose.update_item(conjured).quality == 0
    end

    @tag :skip
    test "Conjured Mana Cake degrade twice fast than normal items" do
      gilded_rose = GildedRose.new()

      conjured = GildedRose.product(gilded_rose, "Conjured Mana Cake")

      GildedRose.update_quality(gilded_rose)

      conjured_updated = GildedRose.product(gilded_rose, "Conjured Mana Cake")

      assert conjured.quality == 6
      assert conjured_updated.quality == 4
      assert conjured.quality - conjured_updated.quality == 2
    end
  end
end

defmodule GildedRoseTest do
  use ExUnit.Case
  doctest GildedRose

  test "interface specification" do
    gilded_rose = GildedRose.new()
    [%GildedRose.Item{} | _] = GildedRose.items(gilded_rose)
    assert :ok == GildedRose.update_quality(gilded_rose)
  end

  describe "regression test" do
    test "ensure that after 1000 days both functions return same value" do
      gilded_rose = GildedRose.new()
      gilded_rose_leeroy = GildedRose.new()

      for day <- 1..1000 do
        GildedRose.update_quality(gilded_rose)
        assert GildedRose.items(gilded_rose) == Helper.find_item_by_day(day)
      end
    end
  end

  describe "new/0" do
    test "init a process id" do
      assert is_pid(GildedRose.new())
    end
  end

  describe "items/1" do
    test "receive a process and respond with list items" do
      gilded_rose = GildedRose.new()
      assert GildedRose.items(gilded_rose) == Helper.find_item_by_day(0)
    end
  end

  describe "update_quality/1 to validate after some days" do
    test "receive a process and respond with updated list items" do
      gilded_rose = GildedRose.new()
      assert :ok = GildedRose.update_quality(gilded_rose)

      assert GildedRose.items(gilded_rose) == Helper.find_item_by_day(1)
    end
  end

  describe "update_quality/1 for generic items" do
    test "if the sell_in days is less than zero, degrades twice fast" do
      gilded_rose = GildedRose.new()

      for _ <- 1..10, do: GildedRose.update_quality(gilded_rose)

      assert %GildedRose.Item{name: "+5 Dexterity Vest", quality: 10, sell_in: 0} ==
               GildedRose.product(gilded_rose, "+5 Dexterity Vest")

      for _ <- 1..5 do
        dexterity = GildedRose.product(gilded_rose, "+5 Dexterity Vest")
        GildedRose.update_quality(gilded_rose)
        dexterity_updated = GildedRose.product(gilded_rose, "+5 Dexterity Vest")

        assert -2 = dexterity_updated.quality - dexterity.quality
        assert -1 = dexterity_updated.sell_in - dexterity.sell_in
      end
    end

    test "quality is never negative" do
      gilded_rose = GildedRose.new()

      for _ <- 1..100, do: assert(:ok = GildedRose.update_quality(gilded_rose))

      Enum.each(GildedRose.items(gilded_rose), fn item ->
        assert item.quality >= 0
      end)
    end

    test "Aged Brie must increase quality when gets old" do
      gilded_rose = GildedRose.new()

      aged_brie = GildedRose.product(gilded_rose, "Aged Brie")
      assert aged_brie.quality == 0
      assert :ok = GildedRose.update_quality(gilded_rose)
      aged_brie_updated = GildedRose.product(gilded_rose, "Aged Brie")
      assert aged_brie_updated.quality == 1
      assert aged_brie.sell_in - aged_brie_updated.sell_in == 1
    end

    test "Quality never more than 50" do
      gilded_rose = GildedRose.new()
      for _ <- 1..100, do: assert(:ok = GildedRose.update_quality(gilded_rose))

      assert GildedRose.product(gilded_rose, "Aged Brie") == %GildedRose.Item{
               name: "Aged Brie",
               quality: 50,
               sell_in: -98
             }
    end
  end

  describe "update_quality/1 for Sulfuras" do
    test "Sultufas sell_in always is always 0" do
      gilded_rose = GildedRose.new()
      for _ <- 1..100, do: assert(:ok = GildedRose.update_quality(gilded_rose))

      assert GildedRose.product(gilded_rose, "Sulfuras, Hand of Ragnaros").sell_in == 0
    end

    test "Sultufas quality is always 80" do
      gilded_rose = GildedRose.new()
      for _ <- 1..100, do: assert(:ok = GildedRose.update_quality(gilded_rose))

      assert GildedRose.product(gilded_rose, "Sulfuras, Hand of Ragnaros").quality == 80
    end
  end

  describe "update_quality/1 for Backstage" do
    test "Backstage passes to a TAFKAL80ETC concert when there is more than 10 days increase quality in 1" do
      gilded_rose = GildedRose.new()

      sell_in =
        GildedRose.product(gilded_rose, "Backstage passes to a TAFKAL80ETC concert").sell_in

      for _ <- 1..(sell_in - 10) do
        backstage = GildedRose.product(gilded_rose, "Backstage passes to a TAFKAL80ETC concert")
        GildedRose.update_quality(gilded_rose)

        updated_backstage =
          GildedRose.product(gilded_rose, "Backstage passes to a TAFKAL80ETC concert")

        assert updated_backstage.quality - backstage.quality == 1
        assert backstage.sell_in - updated_backstage.sell_in == 1
        assert updated_backstage.sell_in >= 10
      end
    end

    test "Backstage passes to a TAFKAL80ETC concert when sell_in is beteween 10 and 6, increase quality in 2" do
      gilded_rose = GildedRose.new()

      sell_in =
        GildedRose.product(gilded_rose, "Backstage passes to a TAFKAL80ETC concert").sell_in

      for _ <- 1..(sell_in - 10), do: GildedRose.update_quality(gilded_rose)

      sell_in =
        GildedRose.product(gilded_rose, "Backstage passes to a TAFKAL80ETC concert").sell_in

      for _ <- 1..(sell_in - 5) do
        backstage = GildedRose.product(gilded_rose, "Backstage passes to a TAFKAL80ETC concert")
        GildedRose.update_quality(gilded_rose)

        updated_backstage =
          GildedRose.product(gilded_rose, "Backstage passes to a TAFKAL80ETC concert")

        assert updated_backstage.quality - backstage.quality == 2
        assert backstage.sell_in - updated_backstage.sell_in == 1
        assert updated_backstage.sell_in >= 5
      end
    end

    test "Backstage passes to a TAFKAL80ETC concert when there is less than 5 days increase quality in 3" do
      gilded_rose = GildedRose.new()

      sell_in =
        GildedRose.product(gilded_rose, "Backstage passes to a TAFKAL80ETC concert").sell_in

      for _ <- 1..(sell_in - 5), do: GildedRose.update_quality(gilded_rose)

      sell_in =
        GildedRose.product(gilded_rose, "Backstage passes to a TAFKAL80ETC concert").sell_in

      for _ <- 1..(sell_in - 5) do
        backstage = GildedRose.product(gilded_rose, "Backstage passes to a TAFKAL80ETC concert")
        GildedRose.update_quality(gilded_rose)

        updated_backstage =
          GildedRose.product(gilded_rose, "Backstage passes to a TAFKAL80ETC concert")

        assert updated_backstage.quality - backstage.quality == 3
        assert backstage.sell_in - updated_backstage.sell_in == 1
        assert updated_backstage.sell_in < 5
      end
    end
  end

  describe "update_quality/1 for Conjured" do
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

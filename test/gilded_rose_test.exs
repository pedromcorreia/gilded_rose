defmodule GildedRoseTest do
  use ExUnit.Case
  doctest GildedRose

  test "interface specification" do
    gilded_rose = GildedRose.new()
    [%GildedRose.Item{} | _] = GildedRose.items(gilded_rose)
    assert :ok == GildedRose.update_quality(gilded_rose)
  end

  describe "new/0" do
    test "init a process id" do
      assert is_pid(GildedRose.new())
    end
  end

  describe "items/1" do
    test "receive a process and respond with list items" do
      gilded_rose = GildedRose.new()

      assert GildedRose.items(gilded_rose) ==
               [
                 %GildedRose.Item{name: "+5 Dexterity Vest", quality: 20, sell_in: 10},
                 %GildedRose.Item{name: "Aged Brie", quality: 0, sell_in: 2},
                 %GildedRose.Item{name: "Elixir of the Mongoose", quality: 7, sell_in: 5},
                 %GildedRose.Item{name: "Sulfuras, Hand of Ragnaros", quality: 80, sell_in: 0},
                 %GildedRose.Item{
                   name: "Backstage passes to a TAFKAL80ETC concert",
                   quality: 20,
                   sell_in: 15
                 },
                 %GildedRose.Item{name: "Conjured Mana Cake", quality: 6, sell_in: 3}
               ]
    end
  end

  describe "update_quality/1" do
    test "receive a process and respond with updated list items" do
      gilded_rose = GildedRose.new()
      assert :ok = GildedRose.update_quality(gilded_rose)

      assert GildedRose.items(gilded_rose) ==
               [
                 %GildedRose.Item{name: "+5 Dexterity Vest", quality: 19, sell_in: 9},
                 %GildedRose.Item{name: "Aged Brie", quality: 1, sell_in: 1},
                 %GildedRose.Item{name: "Elixir of the Mongoose", quality: 6, sell_in: 4},
                 %GildedRose.Item{name: "Sulfuras, Hand of Ragnaros", quality: 80, sell_in: 0},
                 %GildedRose.Item{
                   name: "Backstage passes to a TAFKAL80ETC concert",
                   quality: 21,
                   sell_in: 14
                 },
                 %GildedRose.Item{name: "Conjured Mana Cake", quality: 5, sell_in: 2}
               ]
    end

    test "receive a process and respond with updated list items after 100 days" do
      gilded_rose = GildedRose.new()

      for _ <- 1..100, do: assert(:ok = GildedRose.update_quality(gilded_rose))

      assert GildedRose.items(gilded_rose) ==
               [
                 %GildedRose.Item{name: "+5 Dexterity Vest", quality: 0, sell_in: -90},
                 %GildedRose.Item{name: "Aged Brie", quality: 50, sell_in: -98},
                 %GildedRose.Item{name: "Elixir of the Mongoose", quality: 0, sell_in: -95},
                 %GildedRose.Item{name: "Sulfuras, Hand of Ragnaros", quality: 80, sell_in: 0},
                 %GildedRose.Item{
                   name: "Backstage passes to a TAFKAL80ETC concert",
                   quality: 0,
                   sell_in: -85
                 },
                 %GildedRose.Item{name: "Conjured Mana Cake", quality: 0, sell_in: -97}
               ]
    end

    test "if the sell_in days is less than zero, degrades twice fast" do
      gilded_rose = GildedRose.new()

      for _ <- 1..10, do: GildedRose.update_quality(gilded_rose)

      assert %GildedRose.Item{name: "+5 Dexterity Vest", quality: 10, sell_in: 0} ==
               GildedRose.product(gilded_rose, "+5 Dexterity Vest")

      for _ <- 1..5 do
        dexterity = GildedRose.product(gilded_rose, "+5 Dexterity Vest")
        GildedRose.update_quality(gilded_rose)

        assert -2 =
                 GildedRose.product(gilded_rose, "+5 Dexterity Vest").quality - dexterity.quality
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

      assert GildedRose.product(gilded_rose, "Aged Brie").quality == 0
      assert :ok = GildedRose.update_quality(gilded_rose)
      assert GildedRose.product(gilded_rose, "Aged Brie").quality == 1
    end

    test "Quality never more than 50" do
      gilded_rose = GildedRose.new()
      for _ <- 1..100, do: assert(:ok = GildedRose.update_quality(gilded_rose))
      assert GildedRose.product(gilded_rose, "Aged Brie").quality == 50
    end

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

    @tag :skip
    test "Conjured Mana Cake degrade twice fast than normal itens" do
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

defmodule GildedRoseTest do
  use ExUnit.Case
  doctest GildedRose

  describe "new/0" do
    test "init a process id" do
      assert is_pid(GildedRose.new())
    end
  end

  describe "items/1" do
    test "receive a process and respond with list items" do
      gilded_rose = GildedRose.new()
      assert GildedRose.items(gilded_rose) == find_item_by_day(0)
    end
  end

  describe "update_item/1" do
    test "interface specification" do
      gilded_rose = GildedRose.new()
      [%GildedRose.Item{} | _] = GildedRose.items(gilded_rose)
      assert :ok == GildedRose.update_quality(gilded_rose)
    end

    test "ensure that after 1000 days both functions return same value" do
      gilded_rose = GildedRose.new()

      for day <- 1..1000 do
        GildedRose.update_quality(gilded_rose)
        assert GildedRose.items(gilded_rose) == find_item_by_day(day)
      end
    end
  end

  describe "update_quality/1 for generic items" do
    test "if the sell_in days is less than zero, degrades twice fast" do
      dexterity = %GildedRose.Item{name: "+5 Dexterity Vest", quality: 20, sell_in: -10}
      assert GildedRose.update_item(dexterity).quality == 18
    end

    test "quality is never negative" do
      dexterity = %GildedRose.Item{name: "+5 Dexterity Vest", quality: 0, sell_in: -10}
      assert GildedRose.update_item(dexterity).quality == 0
    end
  end

  describe "update_quality/1 for Aged Brie" do
    test "must increase quality when gets old" do
      aged_brie = %GildedRose.Item{name: "Aged Brie", quality: 0, sell_in: 2}
      assert GildedRose.update_item(aged_brie).quality == 1
    end

    test "must increase quality by two when sell_in expired" do
      aged_brie = %GildedRose.Item{name: "Aged Brie", quality: 0, sell_in: 0}
      assert GildedRose.update_item(aged_brie).quality == 2
    end

    test "quality never more than 50" do
      aged_brie = %GildedRose.Item{name: "Aged Brie", quality: 50, sell_in: 0}
      assert GildedRose.update_item(aged_brie).quality == 50
    end
  end

  describe "update_quality/1 for Sulfuras" do
    test "Sultufas sell_in always is always 0" do
      sulfuras = %GildedRose.Item{name: "Sulfuras, Hand of Ragnaros", quality: 80, sell_in: 0}
      for _ <- 1..100, do: assert(GildedRose.update_item(sulfuras).sell_in == 0)
    end

    test "Sultufas quality is always 80" do
      sulfuras = %GildedRose.Item{name: "Sulfuras, Hand of Ragnaros", quality: 80, sell_in: 0}
      for _ <- 1..100, do: assert(GildedRose.update_item(sulfuras).quality == 80)
    end
  end

  describe "update_item/1 for Backstage" do
    test "Backstage passes to a TAFKAL80ETC concert when there is more than 10 days increase quality in 1" do
      backstage = %GildedRose.Item{
        name: "Backstage passes to a TAFKAL80ETC concert",
        quality: 20,
        sell_in: 11
      }

      assert GildedRose.update_item(backstage).quality == 21
    end

    test "Backstage passes to a TAFKAL80ETC concert when sell_in is beteween 10 and 6, increase quality in 2" do
      backstage = %GildedRose.Item{
        name: "Backstage passes to a TAFKAL80ETC concert",
        quality: 20,
        sell_in: 6
      }

      assert GildedRose.update_item(backstage).quality == 22
    end

    test "Backstage passes to a TAFKAL80ETC concert when there is less than 5 days increase quality in 3" do
      backstage = %GildedRose.Item{
        name: "Backstage passes to a TAFKAL80ETC concert",
        quality: 20,
        sell_in: 2
      }

      assert GildedRose.update_item(backstage).quality == 23
    end
  end

  describe "update_quality/1 for Conjured" do
    test "never degrade less than 0" do
      conjured = %GildedRose.Item{name: "Conjured Mana Cake", quality: 0, sell_in: -3}

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

  defp find_item_by_day(day) when day <= 1000 and day >= 0 do
    File.read!("test/mock/gilded_rose_data.json")
    |> Poison.decode!()
    |> Enum.find(fn x -> x["day"] == day end)
    |> Map.get("product")
    |> string_key_to_atom_map
  end

  defp string_key_to_atom_map(list_string_map) do
    Enum.map(list_string_map, fn string_map ->
      struct(
        GildedRose.Item,
        for({key, val} <- string_map, into: %{}, do: {String.to_atom(key), val})
      )
    end)
  end
end

defmodule ServyTest.WildthingsTest do
  use ExUnit.Case, async: true

  alias Servy.Bear
  alias Servy.Wildthings

  describe "bear_list/0" do
    test "returns the full in-memory catalog" do
      bears = Wildthings.bear_list()

      assert length(bears) == 16
      assert Enum.all?(bears, &match?(%Bear{}, &1))
      assert Enum.find(bears, &(&1.id == 1)).name == "Baloo"
    end
  end

  describe "get_bear/1" do
    test "finds a bear by integer id" do
      assert %Bear{id: 2, name: "Boo", type: "Polar"} = Wildthings.get_bear(2)
    end

    test "finds a bear by binary id" do
      assert %Bear{id: 1, name: "Baloo", hibernating: true} = Wildthings.get_bear("1")
    end

    test "returns nil when the id is unknown" do
      assert Wildthings.get_bear(999) == nil
      assert Wildthings.get_bear("999") == nil
    end
  end
end

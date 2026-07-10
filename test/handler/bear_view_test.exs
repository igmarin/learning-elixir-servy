defmodule ServyTest.BearViewTest do
  use ExUnit.Case, async: true
  doctest Servy.BearView

  alias Servy.Bear
  alias Servy.BearView

  describe "index/1" do
    test "renders a list item per bear" do
      bears = [
        %Bear{id: 1, name: "Baloo"},
        %Bear{id: 2, name: "Boo"}
      ]

      html = BearView.index(bears)

      assert html =~ "<ul>"
      assert html =~ "Bear 1: Baloo"
      assert html =~ "Bear 2: Boo"
    end
  end

  describe "show/1" do
    test "renders id, name, and hibernating flag" do
      bear = %Bear{id: 1, name: "Baloo", hibernating: true}
      html = BearView.show(bear)

      assert html =~ "Bear 1: Baloo"
      assert html =~ "hibernating? true"
    end
  end
end

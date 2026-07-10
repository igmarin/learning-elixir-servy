defmodule RecurseTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  describe "loopy/1" do
    test "prints each head/tail step then Done! for a non-empty list" do
      output =
        capture_io(fn ->
          assert :ok = Recurse.loopy([1, 2, 3])
        end)

      assert output =~ "Head: 1 Tail: [2, 3]"
      assert output =~ "Head: 2 Tail: [3]"
      assert output =~ "Head: 3 Tail: []"
      assert output =~ "Done!"
    end

    test "prints Done! for an empty list" do
      output =
        capture_io(fn ->
          assert :ok = Recurse.loopy([])
        end)

      assert output =~ "Done!"
    end
  end

  describe "factorial/1" do
    test "returns 1 for 0" do
      assert Recurse.factorial(0) == 1
    end

    test "returns the product for a positive integer" do
      assert Recurse.factorial(5) == 120
      assert Recurse.factorial(1) == 1
    end

    test "prints Not possible for a negative integer" do
      output =
        capture_io(fn ->
          assert :ok = Recurse.factorial(-1)
        end)

      assert output =~ "Not possible"
    end

    test "prints Is not an integer for non-integers" do
      output =
        capture_io(fn ->
          assert :ok = Recurse.factorial(1.5)
        end)

      assert output =~ "Is not an integer"
    end
  end
end

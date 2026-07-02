defmodule ServyTest.PluginsTest do
  use ExUnit.Case, async: true
  doctest Servy.Plugins

  import ExUnit.CaptureLog

  alias Servy.Plugins
  alias Servy.Test.Fixtures

  describe "rewrite_path/1" do
    test "maps /wildthings to /wildlife" do
      conv = Fixtures.conv(path: "/wildthings")
      assert Plugins.rewrite_path(conv) == Fixtures.conv(path: "/wildlife")
    end

    test "leaves all other paths unchanged" do
      conv = Fixtures.conv(path: "/anypath")
      assert Plugins.rewrite_path(conv) == conv
    end
  end

  describe "log/1" do
    test "logs the conv and returns it unchanged" do
      conv = Fixtures.conv(path: "/wildlife", method: "GET")

      log =
        capture_log(fn ->
          assert Plugins.log(conv) == conv
        end)

      assert log =~ "/wildlife"
      assert log =~ "GET"
    end
  end
end

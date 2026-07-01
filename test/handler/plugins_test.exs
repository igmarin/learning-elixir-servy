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

  describe "status_reason/1" do
    @status_codes [
      {200, "OK"},
      {201, "Created"},
      {401, "Unauthorized"},
      {403, "Forbidden"},
      {404, "Not Found"},
      {500, "Internal Server Error"}
    ]

    for {code, phrase} <- @status_codes do
      test "returns #{inspect(phrase)} for #{code}" do
        assert Plugins.status_reason(unquote(code)) == unquote(phrase)
      end
    end

    test "returns nil for unknown status codes" do
      assert Plugins.status_reason(418) == nil
      assert Plugins.status_reason(999) == nil
    end
  end
end

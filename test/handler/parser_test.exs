defmodule ServyTest.ParserTest do
  use ExUnit.Case
  doctest Servy.Parser

  describe "handle_name/1" do
    test "200 exists" do
      conv = Servy.Parser.parse_name(%{method: "GET", path: "/about", resp_body: "", status: nil})
      assert conv.path == "/about"
      assert conv.status == 200
    end

    test "404 doesn't exists" do
      conv = Servy.Parser.parse_name(%{method: "GET", path: "/a", resp_body: "", status: nil})
      assert conv.status == 404
    end
  end
end

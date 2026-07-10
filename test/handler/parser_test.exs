defmodule ServyTest.ParserTest do
  use ExUnit.Case, async: true
  doctest Servy.Parser

  alias Servy.Parser
  alias Servy.Test.Fixtures

  @pages_dir Path.expand("../../pages", __DIR__)
  @eisdir_name "__cover_eisdir"
  @eisdir_path Path.join(@pages_dir, @eisdir_name <> ".html")

  describe "parse_name/1" do
    test "returns 200 and HTML content when the page file exists" do
      conv = Fixtures.conv(path: "/about")
      result = Parser.parse_name(conv)

      assert result.path == "/about"
      assert result.status == 200
      assert result.resp_body =~ "<h1>About</h1>"
      assert result.resp_body =~ "<p>Hello</p>"
    end

    test "loads /contact_us from the pages directory" do
      result = Parser.parse_name(Fixtures.conv(path: "/contact_us"))

      assert result.status == 200
      assert result.resp_body =~ "<h1>Contact Us</h1>"
    end

    test "loads nested paths under /info" do
      result = Parser.parse_name(Fixtures.conv(path: "/info/about_me"))

      assert result.status == 200
      assert result.resp_body =~ "<h1>About Me</h1>"
    end

    test "returns 404 when the page file does not exist" do
      result = Parser.parse_name(Fixtures.conv(path: "/missing-page"))

      assert result.status == 404
      assert result.resp_body == "Not found"
    end

    test "returns 500 when the page path is a directory (non-enoent error)" do
      File.mkdir_p!(@eisdir_path)
      on_exit(fn -> File.rm_rf!(@eisdir_path) end)

      result = Parser.parse_name(Fixtures.conv(path: "/#{@eisdir_name}"))

      assert result.status == 500
      assert result.resp_body == :eisdir
    end

    test "preserves method and path on the conv" do
      conv = Fixtures.conv(method: "GET", path: "/about")
      result = Parser.parse_name(conv)

      assert result.method == "GET"
      assert result.path == "/about"
    end
  end
end

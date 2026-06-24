defmodule ServyTest.HandlerTest do
  use ExUnit.Case
  doctest Servy

  test "parse/1 request" do
    request = """
    GET /wildthings HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    assert Servy.Handler.parse(request) == %{method: "GET", path: "/wildthings", resp_body: ""}
    refute Servy.Handler.parse(request) == %{method: "POST", path: "/wildthings", resp_body: ""}
  end

  test "format_response/1" do
    request = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 20

    Bears, Lions, Tigers
    """

    assert Servy.Handler.format_response(request) ==
             "HTTP/1.1 200 OK\nContent-Type: text/html\nContent-Length: 20\n\nBears, Lions, Tigers\n"

    refute Servy.Handler.format_response(request) == "Bears, Lions, Tigers"
  end
end

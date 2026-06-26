defmodule ServyTest.HandlerTest do
  use ExUnit.Case
  doctest Servy

  @request """
  GET /wildthings HTTP/1.1
  Host: example.com
  User-Agent: ExampleBrowser/1.0
  Accept: */*
  """

  @response_body """
  HTTP/1.1 200 OK
  Content-Type: text/html
  Content-Length: 30

  Bears, Lions, Dolphins, Eagles
  """

  describe "handle/1" do
    test "processes the full request pipeline end-to-end" do
      assert Servy.Handler.handle(@request) == @response_body
    end
  end

  describe "parse/1" do
    test "extracts method, path, and initializes resp_body" do
      assert Servy.Handler.parse(@request) == %{method: "GET", path: "/wildthings", resp_body: ""}
    end
  end

  describe "route/1" do
    test "sets the response body on the parsed request" do
      parsed = %{method: "GET", path: "/wildthings", resp_body: ""}
      routed = Servy.Handler.route(parsed)

      assert routed.resp_body == "Bears, Lions, Dolphins, Eagles"
    end
  end

  describe "format_response/1" do
    test "builds a well-formed HTTP response string" do
      request = %{method: "GET", path: "/wildthings", resp_body: "Bears, Lions, Dolphins, Eagles"}

      assert Servy.Handler.format_response(request) == @response_body
    end
  end
end

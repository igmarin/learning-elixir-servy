defmodule ServyTest.HandlerTest do
  use ExUnit.Case, async: true
  doctest Servy.Handler

  alias Servy.Handler
  alias Servy.Test.Fixtures

  @wildlife_body "Bears, Lions, Dolphins, Eagles"

  @request Fixtures.request("GET", "/wildlife")

  @response_body """
  HTTP/1.1 200 OK
  Content-Type: text/html
  Content-Length: 30

  #{@wildlife_body}
  """

  @not_found_response_body """
  HTTP/1.1 404 Not Found
  Content-Type: text/html
  Content-Length: 19

  /notfound Not Found
  """

  describe "handle/1" do
    test "processes the full request pipeline end-to-end" do
      assert Handler.handle(@request) == @response_body
    end

    test "rewrites /wildthings to /wildlife before routing" do
      request = Fixtures.request("GET", "/wildthings")
      response = Handler.handle(request)

      assert response =~ "HTTP/1.1 200 OK"
      assert response =~ @wildlife_body
    end

    test "serves static HTML for /about" do
      response = Handler.handle(Fixtures.request("GET", "/about"))

      assert response =~ "HTTP/1.1 200 OK"
      assert response =~ "<h1>About</h1>"
    end

    test "serves static HTML for /contact_us" do
      response = Handler.handle(Fixtures.request("GET", "/contact_us"))

      assert response =~ "HTTP/1.1 200 OK"
      assert response =~ "<h1>Contact Us</h1>"
    end

    test "serves static HTML for nested /info paths" do
      response = Handler.handle(Fixtures.request("GET", "/info/about_me"))

      assert response =~ "HTTP/1.1 200 OK"
      assert response =~ "<h1>About Me</h1>"
    end
  end

  describe "parse/1" do
    test "extracts method, path, and initializes resp_body and status" do
      assert Handler.parse(@request) ==
               Fixtures.conv(
                 method: "GET",
                 path: "/wildlife",
                 headers: %{
                   "Accept" => "*/*",
                   "Host" => "example.com",
                   "User-Agent" => "ExampleBrowser/1.0"
                 }
               )
    end

    test "reads only the request line from a multi-line request" do
      request = """
      POST /bears HTTP/1.1
      Host: example.com
      User-Agent: ExampleBrowser/1.0
      Accept: */*
      Content-Type: application/x-www-form-urlencoded
      Content-Length: 0

      name=Chester&type=Black
      """

      assert Handler.parse(request) ==
               Fixtures.conv(
                 method: "POST",
                 path: "/bears",
                 headers: %{
                   "Host" => "example.com",
                   "User-Agent" => "ExampleBrowser/1.0",
                   "Accept" => "*/*",
                   "Content-Type" => "application/x-www-form-urlencoded",
                   "Content-Length" => "0"
                 },
                 params: %{"name" => "Chester", "type" => "Black"}
               )
    end
  end

  describe "route/1" do
    test "GET /wildlife returns the wildlife listing with 200" do
      routed = Handler.route(Fixtures.conv(path: "/wildlife"))

      assert routed.status == 200
      assert routed.resp_body == @wildlife_body
    end

    test "GET /bears returns the bear names with 200" do
      routed = Handler.route(Fixtures.conv(path: "/bears"))
      bear_list = Servy.Wildthings.get_bear_list()

      assert routed.status == 200
      assert routed.resp_body == "<ul>#{bear_list}</ul>"
    end

    test "GET /bears/:id returns the bear id with 200" do
      routed = Handler.route(Fixtures.conv(path: "/bears/1"))

      assert routed.status == 200
      assert routed.resp_body == "<h1>Bear 1: Baloo</h1>"
    end

    test "DELETE /bears/:id returns a deletion message with 200" do
      routed = Handler.route(Fixtures.conv(method: "DELETE", path: "/bears/1"))

      assert routed.status == 200
      assert routed.resp_body == "Deleted Bear 1"
    end

    test "POST /bears returns 201 with params" do
      conv =
        Fixtures.conv(
          method: "POST",
          path: "/bears",
          params: %{"name" => "Chester", "type" => "Black"}
        )

      routed = Handler.route(conv)

      assert routed.status == 201
      assert routed.resp_body =~ "created!"
    end

    test "unknown paths return 404 with a not-found message" do
      routed = Handler.route(Fixtures.conv(path: "/notfound"))

      assert routed.status == 404
      assert routed.resp_body == "/notfound Not Found"
    end

    test "GET /about delegates to the parser and serves HTML" do
      routed = Handler.route(Fixtures.conv(path: "/about"))

      assert routed.status == 200
      assert routed.resp_body =~ "<h1>About</h1>"
    end
  end

  describe "format_response/1" do
    test "builds a well-formed 200 HTTP response string" do
      request =
        Fixtures.conv(
          path: "/wildlife",
          resp_body: @wildlife_body,
          status: 200
        )

      assert Handler.format_response(request) == @response_body
    end

    test "builds a well-formed 404 HTTP response string" do
      request =
        Fixtures.conv(
          path: "/notfound",
          resp_body: "/notfound Not Found",
          status: 404
        )

      assert Handler.format_response(request) == @not_found_response_body
    end

    test "includes the correct reason phrase for each status code" do
      for {status, phrase} <- [{201, "Created"}, {500, "Internal Server Error"}] do
        response =
          Fixtures.conv(resp_body: "body", status: status)
          |> Handler.format_response()

        assert response =~ "HTTP/1.1 #{status} #{phrase}"
      end
    end
  end
end

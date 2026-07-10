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

    test "GET /bears returns the bear list HTML" do
      response = Handler.handle(Fixtures.request("GET", "/bears"))

      assert response =~ "HTTP/1.1 200 OK"
      assert response =~ "Bear 1: Baloo"
      assert response =~ "Bear 2: Boo"
    end

    test "GET /bears/:id returns a single bear" do
      response = Handler.handle(Fixtures.request("GET", "/bears/1"))

      assert response =~ "HTTP/1.1 200 OK"
      assert response =~ "Bear 1: Baloo"
      assert response =~ "hibernating? true"
    end

    test "DELETE /bears/:id returns 403 Forbidden" do
      response = Handler.handle(Fixtures.request("DELETE", "/bears/1"))

      assert response =~ "HTTP/1.1 403 Forbidden"
      assert response =~ "Delete a bear is Forbidden"
    end

    test "POST /bears creates with form params" do
      request =
        Fixtures.form_request("POST", "/bears", %{"name" => "Chester", "type" => "Black"})

      response = Handler.handle(request)

      assert response =~ "HTTP/1.1 201 Created"
      assert response =~ "created!"
      assert response =~ "Chester"
      assert response =~ "Black"
    end

    test "unknown paths return 404 through the full pipeline" do
      response = Handler.handle(Fixtures.request("GET", "/notfound"))

      assert response =~ "HTTP/1.1 404 Not Found"
      assert response =~ "/notfound Not Found"
    end
  end

  describe "parse/1" do
    test "extracts method, path, headers, and empty params" do
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

    test "parses form-urlencoded body into params" do
      request =
        Fixtures.form_request("POST", "/bears", %{"name" => "Chester", "type" => "Black"})

      parsed = Handler.parse(request)

      assert parsed.method == "POST"
      assert parsed.path == "/bears"
      assert parsed.params == %{"name" => "Chester", "type" => "Black"}
      assert parsed.headers["Content-Type"] == "application/x-www-form-urlencoded"
      assert parsed.headers["Host"] == "example.com"
      assert is_binary(parsed.headers["Content-Length"])
    end
  end

  describe "parse_headers/1" do
    test "builds a map from header lines" do
      headers =
        Handler.parse_headers([
          "Host: example.com",
          "Accept: */*"
        ])

      assert headers == %{"Host" => "example.com", "Accept" => "*/*"}
    end

    test "returns an empty map for no header lines" do
      assert Handler.parse_headers([]) == %{}
    end
  end

  describe "parse_params/2" do
    test "decodes application/x-www-form-urlencoded bodies" do
      assert Handler.parse_params("application/x-www-form-urlencoded", "name=Chester&type=Black") ==
               %{"name" => "Chester", "type" => "Black"}
    end

    test "returns empty map for other content types" do
      assert Handler.parse_params("application/json", ~s({"name":"Chester"})) == %{}
      assert Handler.parse_params(nil, "name=Chester") == %{}
    end
  end

  describe "route/1" do
    test "GET /wildlife returns the wildlife listing with 200" do
      routed = Handler.route(Fixtures.conv(path: "/wildlife"))

      assert routed.status == 200
      assert routed.resp_body == @wildlife_body
    end

    test "GET /bears returns the bear names with 200" do
      conv = Fixtures.conv(path: "/bears")
      routed = Handler.route(conv)

      assert routed.status == 200
      assert routed.resp_body == Servy.BearController.index(conv).resp_body
    end

    test "GET /bears/:id returns the bear id with 200" do
      conv = Fixtures.conv(path: "/bears/1")
      routed = Handler.route(conv)

      assert routed.status == 200
      assert routed.resp_body == "<h1>Bear 1: Baloo is hibernating? true</h1>\n"
    end

    test "DELETE /bears/:id returns a deletion message with 403" do
      conv = Fixtures.conv(method: "DELETE", path: "/bears/1")
      routed = Handler.route(conv)

      assert routed.status == 403
      assert routed.resp_body == "Delete a bear is Forbidden"
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

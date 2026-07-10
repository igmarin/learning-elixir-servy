defmodule Servy.Test.FixturesTest do
  use ExUnit.Case, async: true

  alias Servy.Test.Fixtures
  alias Servy.Conv

  describe "conv/0 and conv/1" do
    test "defaults to GET /" do
      assert %Conv{method: "GET", path: "/", resp_body: "", status: nil} = Fixtures.conv()
    end

    test "merges field overrides" do
      conv = Fixtures.conv(method: "POST", path: "/bears", status: 201)

      assert conv.method == "POST"
      assert conv.path == "/bears"
      assert conv.status == 201
    end
  end

  describe "request/2" do
    test "builds a request line and default headers" do
      request = Fixtures.request("GET", "/wildlife")

      assert request =~ "GET /wildlife HTTP/1.1"
      assert request =~ "Host: example.com"
      assert request =~ "User-Agent: ExampleBrowser/1.0"
      assert request =~ "Accept: */*"
    end
  end

  describe "request/3 and request/4" do
    test "includes body and Content-Length" do
      request = Fixtures.request("POST", "/bears", "name=Chester")

      assert request =~ "POST /bears HTTP/1.1"
      assert request =~ "Content-Length: 12"
      assert request =~ "name=Chester"
      refute request =~ "Content-Type:"
    end

    test "adds Content-Type when given" do
      request =
        Fixtures.request("POST", "/bears", "name=Chester",
          content_type: "application/x-www-form-urlencoded"
        )

      assert request =~ "Content-Type: application/x-www-form-urlencoded"
      assert request =~ "Content-Length: 12"
    end

    test "omits Content-Length for empty body" do
      request = Fixtures.request("GET", "/about", "")

      refute request =~ "Content-Length:"
    end
  end

  describe "form_request/3" do
    test "encodes params and sets form content type" do
      request =
        Fixtures.form_request("POST", "/bears", %{"name" => "Chester", "type" => "Black"})

      assert request =~ "POST /bears HTTP/1.1"
      assert request =~ "Content-Type: application/x-www-form-urlencoded"
      assert request =~ "name=Chester"
      assert request =~ "type=Black"
    end
  end
end

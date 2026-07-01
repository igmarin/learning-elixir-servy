defmodule ServyTest.PluginsTest do
  use ExUnit.Case
  doctest Servy.Plugins

  describe "rewrite_path/1" do
    test "/wildthings to /wildlife" do
      conv = %{method: "GET", path: "/wildthings", resp_body: "", status: nil}
      assert Servy.Plugins.rewrite_path(conv) == %{conv | path: "/wildlife"}
    end

    test "/anypath" do
      conv = %{method: "GET", path: "/anypath", resp_body: "", status: nil}
      assert Servy.Plugins.rewrite_path(conv) == %{conv | path: "/anypath"}
    end
  end

  describe "log/1" do
    test "echo", do: assert(Servy.Plugins.log("echo") == "echo")
  end

  describe "status_reason/1" do
    test "200", do: assert(Servy.Plugins.status_reason(200) == "OK")
    test "201", do: assert(Servy.Plugins.status_reason(201) == "Created")
    test "401", do: assert(Servy.Plugins.status_reason(401) == "Unauthorized")
    test "403", do: assert(Servy.Plugins.status_reason(403) == "Forbidden")
    test "404", do: assert(Servy.Plugins.status_reason(404) == "Not Found")
    test "500", do: assert(Servy.Plugins.status_reason(500) == "Internal Server Error")
  end
end

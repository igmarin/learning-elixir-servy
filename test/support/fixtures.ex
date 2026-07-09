defmodule Servy.Test.Fixtures do
  @moduledoc """
  Shared builders for request and conversation (`conv`) structs used in tests.

  A **conv** is the `%Servy.Conv{}` struct that flows through the handler pipeline.
  """

  alias Servy.Conv

  @doc "Builds a conv struct with sensible defaults, merged with `headers`."
  def conv(headers \\ []) do
    struct(%Conv{method: "GET", path: "/"}, headers)
  end

  @doc "Builds a minimal HTTP/1.1 request string for the given method and path."
  def request(method, path) do
    """
    #{method} #{path} HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """
  end

  def request(method, path, body) do
    """
    #{method} #{path} HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    #{body}
    """
  end
end

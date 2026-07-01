defmodule Servy.Test.Fixtures do
  @moduledoc """
  Shared builders for request and conversation (`conv`) maps used in tests.

  A **conv** is the map that flows through the handler pipeline:

      %{method: String.t(), path: String.t(), resp_body: String.t(), status: integer() | nil}
  """

  @doc "Builds a conv map with sensible defaults, merged with `overrides`."
  def conv(overrides \\ []) do
    %{method: "GET", path: "/", resp_body: "", status: nil}
    |> Map.merge(Map.new(overrides))
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
end

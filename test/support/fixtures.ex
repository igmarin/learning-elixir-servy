defmodule Servy.Test.Fixtures do
  @moduledoc """
  Shared builders for HTTP request strings and conversation (`conv`) structs.

  A **conv** is the `%Servy.Conv{}` that flows through the handler pipeline.
  Prefer these helpers over hand-rolled multi-line strings so parse headers,
  form bodies, and defaults stay consistent across the suite.

  ## Examples

      conv = Servy.Test.Fixtures.conv()
      conv = Servy.Test.Fixtures.conv(method: "DELETE", path: "/bears/1")

      Servy.Test.Fixtures.request("GET", "/wildlife")
      Servy.Test.Fixtures.form_request("POST", "/bears", %{"name" => "Chester", "type" => "Black"})
  """

  alias Servy.Conv

  @doc """
  Builds a conv struct with defaults `method: "GET"` and `path: "/"`.

  Pass a keyword list of field overrides (same keys as `%Servy.Conv{}`).
  """
  def conv(overrides \\ []) do
    struct(%Conv{method: "GET", path: "/"}, overrides)
  end

  @doc """
  Builds a minimal HTTP/1.1 request string with no body.

  Includes Host, User-Agent, and Accept headers used throughout the suite.
  """
  def request(method, path) do
    request(method, path, "", [])
  end

  @doc """
  Builds an HTTP/1.1 request string with an optional body.

  When `body` is non-empty, `Content-Length` is set automatically.

  ## Options

    * `:content_type` - value for the `Content-Type` header (omit when none)

  ## Examples

      Fixtures.request("POST", "/bears", "name=Chester",
        content_type: "application/x-www-form-urlencoded")
  """
  def request(method, path, body, opts \\ []) when is_binary(body) and is_list(opts) do
    content_type = Keyword.get(opts, :content_type)

    extra_headers =
      []
      |> maybe_header("Content-Type", content_type)
      |> maybe_content_length(body)

    header_block =
      (["Host: example.com", "User-Agent: ExampleBrowser/1.0", "Accept: */*"] ++ extra_headers)
      |> Enum.join("\n")

    """
    #{method} #{path} HTTP/1.1
    #{header_block}

    #{body}
    """
  end

  @doc """
  Builds a form-urlencoded POST-style request from a params map.

  Encodes `params` with `URI.encode_query/1` and sets
  `Content-Type: application/x-www-form-urlencoded`.
  """
  def form_request(method, path, params) when is_map(params) do
    body = URI.encode_query(params)
    request(method, path, body, content_type: "application/x-www-form-urlencoded")
  end

  defp maybe_header(headers, _name, nil), do: headers
  defp maybe_header(headers, name, value), do: headers ++ ["#{name}: #{value}"]

  defp maybe_content_length(headers, ""), do: headers

  defp maybe_content_length(headers, body) do
    headers ++ ["Content-Length: #{byte_size(body)}"]
  end
end

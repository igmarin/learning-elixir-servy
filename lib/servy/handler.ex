defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests by parsing, routing, and formatting responses.
  """

  import Servy.Plugins, only: [log: 1, rewrite_path: 1, status_reason: 1]
  import Servy.Parser, only: [parse_name: 1]

  @doc "Transforms an HTTP request into a response by parsing, routing, and formatting."
  def handle(request) do
    request
    |> log()
    |> parse()
    |> rewrite_path()
    |> route()
    |> format_response()
  end

  @doc "Parses the request into a `Conv` struct."
  def parse(request) do
    [method, path, _] = request |> String.split("\n") |> List.first() |> String.split(" ")

    %{method: method, path: path, resp_body: "", status: nil}
  end

  def route(%{method: "GET", path: "/about"} = conv), do: parse_name(conv)
  def route(%{method: "GET", path: "/contact_us"} = conv), do: parse_name(conv)
  def route(%{method: "GET", path: "/info" <> _name} = conv), do: parse_name(conv)

  def route(%{method: "GET", path: "/wildlife"} = conv) do
    %{conv | resp_body: "Bears, Lions, Dolphins, Eagles", status: 200}
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{conv | resp_body: "Teddy, Smokey, Paddingtong", status: 200}
  end

  def route(%{method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%{method: "DELETE", path: "/bears/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Deleted Bear #{id}"}
  end

  def route(%{path: path} = conv) do
    %{conv | resp_body: "#{path} Not Found", status: 404}
  end

  def format_response(request) do
    """
    HTTP/1.1 #{request.status} #{status_reason(request.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(request.resp_body)}

    #{request.resp_body}
    """
  end
end

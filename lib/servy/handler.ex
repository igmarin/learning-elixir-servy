defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests by parsing, routing, and formatting responses.
  """

  require Logger

  def handle(request) do
    request |> log |> parse() |> rewrite_path() |> route() |> format_response()
  end

  def rewrite_path(%{path: "/wildthings"} = conv) do
    %{conv | path: "/wildlife"}
  end

  def rewrite_path(conv), do: conv

  defp log(conv) do
    Logger.debug(inspect(conv))
    conv
  end

  def parse(request) do
    [method, path, _] = request |> String.split("\n") |> List.first() |> String.split(" ")

    %{method: method, path: path, resp_body: "", status: nil}
  end

  def route(conv) do
    route(conv, conv.method, conv.path)
  end

  def route(conv, "GET", "/wildlife") do
    %{conv | resp_body: "Bears, Lions, Dolphins, Eagles", status: 200}
  end

  def route(conv, "GET", "/bears") do
    %{conv | resp_body: "Teddy, Smokey, Paddingtong", status: 200}
  end

  def route(conv, _method, _path) do
    %{conv | resp_body: "Not Found", status: 404}
  end

  def format_response(request) do
    """
    HTTP/1.1 #{request.status} #{status_reason(request.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(request.resp_body)}

    #{request.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end

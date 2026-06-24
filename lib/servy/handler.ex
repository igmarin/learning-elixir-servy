defmodule Servy.Handler do
  def handle(request) do
    request |> parse() |> route() |> format_response()
  end

  def parse(request) do
    [method, path, _] = request |> String.split("\n") |> List.first() |> String.split(" ")
    %{method: method, path: path, resp_body: ""}
  end

  def route(request) do
  end

  def format_response(request) do
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 20

    Bears, Lions, Tigers
    """
  end
end

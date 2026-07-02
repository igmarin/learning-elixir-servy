defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests by parsing, routing, and formatting responses.

  Requests flow through a **conv** (conversation) struct (`%Servy.Conv{}`):

      %Servy.Conv{method: "GET", path: "/wildlife", resp_body: "", status: nil}

  ## Pipeline

      request string
        |> log/1           # Servy.Plugins
        |> parse/1         # extract method and path
        |> rewrite_path/1  # Servy.Plugins
        |> route/1         # set status and body
        |> format_response/1

  ## Routing

  | Method   | Path            | Response                          |
  |----------|-----------------|-----------------------------------|
  | `GET`    | `/wildlife`     | Wildlife listing                  |
  | `GET`    | `/bears`        | Bear names                        |
  | `GET`    | `/bears/:id`    | Single bear                       |
  | `DELETE` | `/bears/:id`    | Deletion confirmation             |
  | `GET`    | `/about`        | Static HTML from `pages/`         |
  | `GET`    | `/contact_us`   | Static HTML from `pages/`         |
  | `GET`    | `/info/*`       | Static HTML from `pages/info/`    |
  | *        | * (unmatched)   | `404` with `"{path} Not Found"`   |
  """

  alias Servy.Conv
  import Servy.Plugins, only: [log: 1, rewrite_path: 1]
  import Servy.Parser, only: [parse_name: 1]

  @doc """
  Transforms a raw HTTP request string into a formatted HTTP response.

  ## Examples

      iex> request = \"""
      ...> GET /wildlife HTTP/1.1
      ...> Host: example.com
      ...>
      ...> \"""
      iex> response = Servy.Handler.handle(request)
      iex> response =~ "HTTP/1.1 200 OK"
      true
      iex> response =~ "Bears, Lions, Dolphins, Eagles"
      true

  """
  def handle(request) do
    request
    |> log()
    |> parse()
    |> rewrite_path()
    |> route()
    |> format_response()
  end

  @doc """
  Parses the request line into a conv struct.

  Only the first line of the request is read; headers and body are ignored.

  ## Examples

      iex> request = "GET /wildlife HTTP/1.1\\nHost: example.com\\n"
      iex> Servy.Handler.parse(request)
      %Servy.Conv{method: "GET", path: "/wildlife", resp_body: "", status: nil}

  """
  def parse(request) do
    [method, path, _] = request |> String.split("\n") |> List.first() |> String.split(" ")

    %Conv{method: method, path: path}
  end

  @doc """
  Matches the conv's method and path, setting `status` and `resp_body`.

  Unmatched routes receive a `404` status with body `"{path} Not Found"`.

  ## Examples

      iex> conv = %Servy.Conv{method: "GET", path: "/wildlife"}
      iex> routed = Servy.Handler.route(conv)
      iex> routed.status
      200
      iex> routed.resp_body
      "Bears, Lions, Dolphins, Eagles"

      iex> conv = %Servy.Conv{method: "GET", path: "/unknown"}
      iex> Servy.Handler.route(conv).status
      404

  """
  def route(%Conv{method: "GET", path: "/about"} = conv), do: parse_name(conv)
  def route(%Conv{method: "GET", path: "/contact_us"} = conv), do: parse_name(conv)
  def route(%Conv{method: "GET", path: "/info" <> _name} = conv), do: parse_name(conv)

  def route(%Conv{method: "GET", path: "/wildlife"} = conv) do
    %{conv | resp_body: "Bears, Lions, Dolphins, Eagles", status: 200}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    %{conv | resp_body: "Teddy, Smokey, Paddingtong", status: 200}
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Deleted Bear #{id}"}
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    %{conv | status: 201, resp_body: "Bear created!"}
  end

  def route(%Conv{path: path} = conv) do
    %{conv | resp_body: "#{path} Not Found", status: 404}
  end

  @doc """
  Formats a conv into a complete HTTP/1.1 response string.

  The response includes the status line, `Content-Type`, `Content-Length`,
  a blank line, and the response body.

  ## Examples

      iex> conv = %Servy.Conv{method: "GET", path: "/wildlife", resp_body: "Hello", status: 200}
      iex> Servy.Handler.format_response(conv)
      "HTTP/1.1 200 OK\\nContent-Type: text/html\\nContent-Length: 5\\n\\nHello\\n"

  """
  def format_response(request) do
    """
    HTTP/1.1 #{Conv.display_status(request)}
    Content-Type: text/html
    Content-Length: #{byte_size(request.resp_body)}

    #{request.resp_body}
    """
  end
end

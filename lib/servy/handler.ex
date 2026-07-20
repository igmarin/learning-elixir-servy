defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests by parsing, routing, and formatting responses.

  Requests flow through a **conv** (conversation) struct (`%Servy.Conv{}`):

      %Servy.Conv{headers: %{}, method: "GET", path: "/wildlife", resp_body: "", status: nil}

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
  | `GET`    | `/bears`        | Bear list HTML                    |
  | `GET`    | `/bears/:id`    | Single bear HTML                  |
  | `POST`   | `/bears`        | Create bear from form params      |
  | `DELETE` | `/bears/:id`    | Forbidden (`403`)                 |
  | `GET`    | `/api/bears`    | Bear list JSON (`application/json`) |
  | `GET`    | `/about`        | Static HTML from `pages/`         |
  | `GET`    | `/contact_us`   | Static HTML from `pages/`         |
  | `GET`    | `/info/*`       | Static HTML from `pages/info/`    |
  | *        | * (unmatched)   | `404` with `"{path} Not Found"`   |
  """

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.Api.BearController, as: ApiBearController
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
  Parses a raw HTTP request into a conv struct.

  Extracts the request line (method, path), headers, and body params when
  `Content-Type` is `application/x-www-form-urlencoded`.

  ## Examples

      iex> request = "GET /wildlife HTTP/1.1\\nHost: example.com\\n\\n"
      iex> Servy.Handler.parse(request)
      %Servy.Conv{headers: %{"Host" => "example.com"}, method: "GET", path: "/wildlife", resp_body: "", status: nil, params: %{}}

      iex> request = "POST /bears HTTP/1.1\\nHost: example.com\\nContent-Type: application/x-www-form-urlencoded\\n\\nname=Chester&type=Black"
      iex> Servy.Handler.parse(request)
      %Servy.Conv{headers: %{"Host" => "example.com", "Content-Type" => "application/x-www-form-urlencoded"}, method: "POST", path: "/bears", resp_body: "", status: nil, params: %{"name" => "Chester", "type" => "Black"}}

  """
  def parse(request) do
    request = String.replace(request, "\r\n", "\n")

    [top, params_string] = String.split(request, "\n\n")
    [request_line | header_lines] = String.split(top, "\n")
    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines)
    params = parse_params(headers["Content-Type"], params_string)

    %Conv{method: method, path: path, params: params, headers: headers}
  end

  @doc """
  Parses header lines into a map of header name => value.

  Each line must be `"Name: value"` (colon + space). Order of keys is not
  significant; later lines with the same name overwrite earlier ones.

  ## Examples

      iex> Servy.Handler.parse_headers(["Host: example.com", "Accept: */*"])
      %{"Host" => "example.com", "Accept" => "*/*"}

      iex> Servy.Handler.parse_headers([])
      %{}

  """
  def parse_headers(header_lines) do
    Enum.reduce(header_lines, %{}, fn line, headers_so_far ->
      [key, value] = String.split(line, ": ")
      Map.put(headers_so_far, key, value)
    end)
  end

  @doc """
  Parses the request body into a params map based on `Content-Type`.

  Currently only `application/x-www-form-urlencoded` bodies are decoded via
  `URI.decode_query/1`. Any other content type (or `nil`) yields `%{}`.

  ## Examples

      iex> Servy.Handler.parse_params("application/x-www-form-urlencoded", "name=Chester&type=Black")
      %{"name" => "Chester", "type" => "Black"}

      iex> Servy.Handler.parse_params("application/json", ~s({"name":"Chester"}))
      %{}

      iex> Servy.Handler.parse_params(nil, "name=Chester")
      %{}

  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim() |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}

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
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    ApiBearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    BearController.show(conv, %{"id" => id})
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    BearController.delete(conv, %{"id" => id})
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    %{conv | status: 201, resp_body: "#{inspect(conv.params)} created!"}
  end

  def route(%Conv{path: path} = conv) do
    %{conv | resp_body: "#{path} Not Found", status: 404}
  end

  @doc """
  Formats a conv into a complete HTTP/1.1 response string.

  The response includes the status line, `Content-Type` (from
  `Servy.Conv.resp_content_type/1`), `Content-Length`, a blank line, and the
  response body.

  ## Examples

      iex> conv = %Servy.Conv{method: "GET", path: "/wildlife", resp_body: "Hello", status: 200}
      iex> Servy.Handler.format_response(conv)
      "HTTP/1.1 200 OK\\nContent-Type: text/html\\nContent-Length: 5\\n\\nHello\\n"

  """
  def format_response(request) do
    """
    HTTP/1.1 #{Conv.display_status(request)}
    Content-Type: #{Conv.resp_content_type(request)}
    Content-Length: #{byte_size(request.resp_body)}

    #{request.resp_body}
    """
  end
end

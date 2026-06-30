defmodule Servy.Plugins do
  @moduledoc """
  Helper functions for the Servy HTTP handler.
  """

  require Logger

  @doc "Rewrites the path of the request to map `/wildthings` to `/wildlife`."
  def rewrite_path(%{path: "/wildthings"} = conv), do: %{conv | path: "/wildlife"}
  def rewrite_path(conv), do: conv

  @doc "Logs the request."
  def log(conv) do
    Logger.info(inspect(conv))
    conv
  end

  @doc "Returns the reason phrase for the given status code."
  def status_reason(code) do
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

defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests by parsing, routing, and formatting responses.
  """

  import Servy.Plugins, only: [log: 1, rewrite_path: 1, status_reason: 1]

  @page_dir Path.expand("../../pages", __DIR__)

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

  @doc "Handles the file response based on the file read result."
  def handle_file({:ok, content}, conv), do: %{conv | status: 200, resp_body: content}
  def handle_file({:error, :enoent}, conv), do: %{conv | status: 404, resp_body: "File not found"}
  def handle_file({:error, reason}, conv), do: %{conv | status: 500, resp_body: reason}

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

  defp parse_name(conv) do
    file_name = Path.join(@page_dir, conv.path <> ".html")
    handle_file(File.read(file_name), conv)
  end
end

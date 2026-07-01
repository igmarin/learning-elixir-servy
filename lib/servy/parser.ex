defmodule Servy.Parser do
  @moduledoc """
  Loads static HTML pages from the `pages/` directory.

  Page files are resolved by joining the request path with `.html`:

      GET /about       → pages/about.html
      GET /info/about_me → pages/info/about_me.html

  ## Error handling

  | `File.read/1` result | Status | Body        |
  |----------------------|--------|-------------|
  | `{:ok, content}`     | `200`  | file content |
  | `{:error, :enoent}`  | `404`  | `"Not found"` |
  | `{:error, reason}`   | `500`  | `reason`     |
  """

  @page_dir Path.expand("../../pages", __DIR__)

  @doc """
  Reads the HTML page for the conv's path and updates `status` and `resp_body`.

  ## Examples

      iex> conv = %{method: "GET", path: "/about", resp_body: "", status: nil}
      iex> result = Servy.Parser.parse_name(conv)
      iex> result.status
      200
      iex> result.resp_body =~ "<h1>About</h1>"
      true

      iex> conv = %{method: "GET", path: "/does-not-exist", resp_body: "", status: nil}
      iex> Servy.Parser.parse_name(conv)
      %{method: "GET", path: "/does-not-exist", resp_body: "Not found", status: 404}

  """
  def parse_name(conv) do
    file_name = Path.join(@page_dir, conv.path <> ".html")
    handle_file(File.read(file_name), conv)
  end

  defp handle_file({:ok, content}, conv), do: %{conv | status: 200, resp_body: content}
  defp handle_file({:error, :enoent}, conv), do: %{conv | status: 404, resp_body: "Not found"}
  defp handle_file({:error, reason}, conv), do: %{conv | status: 500, resp_body: reason}
end

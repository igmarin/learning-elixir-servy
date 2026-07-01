defmodule Servy.Parser do
  @moduledoc """
    Handles files from pages
  """
  @page_dir Path.expand("../../pages", __DIR__)

  @doc "Check for the html path"
  def parse_name(conv) do
    file_name = Path.join(@page_dir, conv.path <> ".html")
    handle_file(File.read(file_name), conv)
  end

  defp handle_file({:ok, content}, conv), do: %{conv | status: 200, resp_body: content}
  defp handle_file({:error, :enoent}, conv), do: %{conv | status: 404, resp_body: "Not found"}
  defp handle_file({:error, reason}, conv), do: %{conv | status: 500, resp_body: reason}
end

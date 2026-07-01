defmodule Servy.Plugins do
  @moduledoc """
  Plug-style transformations used in the `Servy.Handler` request pipeline.

  Each function accepts a conv map and returns an updated conv (or the same conv
  when no change is needed). Functions are composed with the pipe operator in
  `Servy.Handler.handle/1`.
  """

  require Logger

  @doc """
  Rewrites `/wildthings` to `/wildlife` so legacy URLs keep working.

  All other paths pass through unchanged.

  ## Examples

      iex> conv = %{method: "GET", path: "/wildthings", resp_body: "", status: nil}
      iex> Servy.Plugins.rewrite_path(conv)
      %{method: "GET", path: "/wildlife", resp_body: "", status: nil}

      iex> conv = %{method: "GET", path: "/bears", resp_body: "", status: nil}
      iex> Servy.Plugins.rewrite_path(conv)
      %{method: "GET", path: "/bears", resp_body: "", status: nil}

  """
  def rewrite_path(%{path: "/wildthings"} = conv), do: %{conv | path: "/wildlife"}
  def rewrite_path(conv), do: conv

  @doc """
  Logs the conv at `:info` level and returns it unchanged.

  ## Examples

      iex> Servy.Plugins.log("echo")
      "echo"

  """
  def log(conv) do
    Logger.info(inspect(conv))
    conv
  end

  @doc """
  Returns the HTTP reason phrase for a status code.

  Returns `nil` when the code is not in the lookup table.

  ## Examples

      iex> Servy.Plugins.status_reason(200)
      "OK"

      iex> Servy.Plugins.status_reason(404)
      "Not Found"

      iex> Servy.Plugins.status_reason(418)
      nil

  """
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

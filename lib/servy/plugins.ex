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

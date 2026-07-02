defmodule Servy.Plugins do
  @moduledoc """
  Plug-style transformations used in the `Servy.Handler` request pipeline.

  Each function accepts a `%Servy.Conv{}` struct and returns an updated conv (or
  the same conv when no change is needed). Functions are composed with the pipe
  operator in `Servy.Handler.handle/1`.
  """

  alias Servy.Conv
  require Logger

  @doc """
  Rewrites `/wildthings` to `/wildlife` so legacy URLs keep working.

  All other paths pass through unchanged.

  ## Examples

      iex> conv = %Servy.Conv{method: "GET", path: "/wildthings"}
      iex> Servy.Plugins.rewrite_path(conv)
      %Servy.Conv{method: "GET", path: "/wildlife", resp_body: "", status: nil}

      iex> conv = %Servy.Conv{method: "GET", path: "/bears"}
      iex> Servy.Plugins.rewrite_path(conv)
      %Servy.Conv{method: "GET", path: "/bears", resp_body: "", status: nil}

  """
  def rewrite_path(%Conv{path: "/wildthings"} = conv), do: %{conv | path: "/wildlife"}
  def rewrite_path(%Conv{} = conv), do: conv

  @doc """
  Logs the given value at `:info` level and returns it unchanged.

  In the handler pipeline this is the raw request string; later steps pass
  `%Servy.Conv{}` structs.

  ## Examples

      iex> Servy.Plugins.log("echo")
      "echo"

  """
  def log(value) do
    Logger.info(inspect(value))
    value
  end
end

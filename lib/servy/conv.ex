defmodule Servy.Conv do
  @moduledoc """
  Struct representing a request as it moves through the handler pipeline.

  A **conv** (conversation) carries request details and the emerging response as
  data flows through `Servy.Handler` and plug-style transforms in
  `Servy.Plugins`.

  ## Fields

    * `:method` - HTTP verb from the request line (e.g. `"GET"`)
    * `:path` - Request path (e.g. `"/wildlife"`)
    * `:resp_body` - Response body string, initially `""`
    * `:status` - HTTP status code as an integer, or `nil` before routing

  ## Examples

      iex> conv = %Servy.Conv{method: "GET", path: "/wildlife"}
      iex> conv.status
      nil

  `display_status/1` also accepts plain maps with a `:status` key for flexibility.
  """

  @typedoc "Conversation struct flowing through the handler pipeline."
  @type t :: %__MODULE__{
          method: String.t(),
          path: String.t(),
          resp_body: String.t(),
          status: non_neg_integer() | nil
        }

  defstruct method: "", path: "", resp_body: "", status: nil

  @doc """
  Formats the HTTP status line fragment as `"<code> <reason>"`.

  Used by `Servy.Handler.format_response/1` to build the response status line.
  When the status code has no known reason phrase, returns `"Status unknown"`.

  ## Examples

      iex> Servy.Conv.display_status(%Servy.Conv{status: 200})
      "200 OK"

      iex> Servy.Conv.display_status(%Servy.Conv{status: 404})
      "404 Not Found"

      iex> Servy.Conv.display_status(%{status: 200})
      "200 OK"

      iex> Servy.Conv.display_status(%Servy.Conv{status: 418})
      "Status unknown"

  """
  def display_status(%{status: status}) do
    case status_reason(status) do
      nil -> "Status unknown"
      phrase -> "#{status} #{phrase}"
    end
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

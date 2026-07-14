defmodule Servy.Api.BearController do
  @moduledoc """
  JSON API actions for bear resources.

  Unlike `Servy.BearController` (HTML via EEx), this module returns JSON and sets
  `resp_content_type` to `"application/json"` so `Servy.Handler.format_response/1`
  emits the correct `Content-Type` header.

  | Action    | Method / path (via Handler) | Status | Body |
  |-----------|-----------------------------|--------|------|
  | `index/1` | `GET /api/bears`            | `200`  | JSON array of bears |
  | `post/1` | `POST /api/bears`            | `201`  | JSON array of bears |

  Encoding uses [Jason](https://hex.pm/packages/jason).
  """

  @doc """
  Lists all bears as JSON (`200`, `Content-Type: application/json`).

  Encodes `Servy.Wildthings.bear_list/0` with `Jason.encode!/1` and sets
  `resp_content_type` on the conv.

  ## Examples

      iex> conv = %Servy.Conv{method: "GET", path: "/api/bears"}
      iex> result = Servy.Api.BearController.index(conv)
      iex> result.status
      200
      iex> result.resp_content_type
      "application/json"
      iex> result.resp_body =~ "Baloo"
      true

  """
  def index(conv) do
    json = Jason.encode!(Servy.Wildthings.bear_list())
    %{conv | status: 200, resp_body: json, resp_content_type: "application/json"}
  end

  def create(conv, %{name: name, type: type}) do
    json = Jason.encode!(%{name: name, type: type})
    %{conv | status: 201, resp_body: json, resp_content_type: "application/json"}
  end
end

defmodule Servy.BearController do
  @moduledoc """
  HTTP actions for bear resources.

  Loads data from `Servy.Wildthings` and HTML from `Servy.BearView`, then updates
  the `%Servy.Conv{}` with `status` and `resp_body`.

  | Action     | Method / path (via Handler) | Status | Body |
  |------------|-----------------------------|--------|------|
  | `index/1`  | `GET /bears`                | `200`  | list HTML |
  | `show/2`   | `GET /bears/:id`            | `200`  | show HTML |
  | `delete/2` | `DELETE /bears/:id`         | `403`  | forbidden message |

  Rendering is delegated to the view layer so this module stays free of EEx paths
  and template details.
  """

  alias Servy.Wildthings
  alias Servy.BearView

  @doc """
  Lists all bears as HTML (`200`).

  ## Examples

      iex> conv = %Servy.Conv{method: "GET", path: "/bears"}
      iex> result = Servy.BearController.index(conv)
      iex> result.status
      200
      iex> result.resp_body =~ "Bear 1: Baloo"
      true

  """
  def index(conv) do
    bears = Wildthings.bear_list()
    %{conv | resp_body: BearView.index(bears), status: 200}
  end

  @doc """
  Shows one bear by id as HTML (`200`).

  `params` must include `"id"` (string), matching the route capture from
  `Servy.Handler.route/1`.

  ## Examples

      iex> conv = %Servy.Conv{method: "GET", path: "/bears/1"}
      iex> result = Servy.BearController.show(conv, %{"id" => "1"})
      iex> result.status
      200
      iex> result.resp_body =~ "Bear 1: Baloo"
      true

  """
  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    %{conv | resp_body: BearView.show(bear), status: 200}
  end

  @doc """
  Rejects bear deletion with `403 Forbidden`.

  The id argument is ignored; all deletes are forbidden.

  ## Examples

      iex> conv = %Servy.Conv{method: "DELETE", path: "/bears/1"}
      iex> Servy.BearController.delete(conv, %{"id" => "1"})
      %Servy.Conv{
        method: "DELETE",
        path: "/bears/1",
        params: %{},
        resp_body: "Delete a bear is Forbidden",
        headers: %{},
        status: 403
      }

  """
  def delete(conv, _id) do
    %{conv | resp_body: "Delete a bear is Forbidden", status: 403}
  end
end

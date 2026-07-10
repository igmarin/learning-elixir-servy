defmodule Servy.BearView do
  @moduledoc """
  Compiles EEx templates under `templates/` into view functions for bears.

  Templates are loaded at **compile time** via `EEx.function_from_file/4`, so
  changes to `.eex` files require a recompile to take effect.

  | Function   | Template              | Binding |
  |------------|-----------------------|---------|
  | `index/1`  | `templates/index.eex` | `bears` |
  | `show/1`   | `templates/show.eex`  | `bear`  |

  Controllers call these functions and set `resp_body` / `status` on the conv.
  See `Servy.BearController`.
  """

  require EEx

  @template_path Path.expand("../../templates", __DIR__)

  @doc """
  Renders the bears index HTML from `templates/index.eex`.

  ## Examples

      iex> html = Servy.BearView.index([%Servy.Bear{id: 1, name: "Baloo"}])
      iex> html =~ "Bear 1: Baloo"
      true

  """
  EEx.function_from_file(:def, :index, Path.join(@template_path, "index.eex"), [:bears])

  @doc """
  Renders a single bear show page from `templates/show.eex`.

  ## Examples

      iex> bear = %Servy.Bear{id: 1, name: "Baloo", hibernating: true}
      iex> html = Servy.BearView.show(bear)
      iex> html =~ "Bear 1: Baloo"
      true
      iex> html =~ "hibernating? true"
      true

  """
  EEx.function_from_file(:def, :show, Path.join(@template_path, "show.eex"), [:bear])
end

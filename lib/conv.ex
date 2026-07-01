defmodule Servy.Conv do
  import Servy.Plugins

  @moduledoc """
  Struct representing a request as it moves through the handler pipeline.
  """

  defstruct method: "", path: "", resp_body: "", status: nil

  def full_status(conv) do
    "#{conv.status} #{status_reason(conv.status)}"
  end
end

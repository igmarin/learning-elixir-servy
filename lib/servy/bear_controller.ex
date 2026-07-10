defmodule Servy.BearController do
  alias Servy.Wildthings

  @templates_path Path.expand("../../templates", __DIR__)

  defp render(conv, template, bindings) do
    content = @templates_path |> Path.join(template) |> EEx.eval_file(bindings)
    %{conv | resp_body: content, status: 200}
  end

  def index(conv) do
    bears = Wildthings.bear_list()
    render(conv, "index.eex", bears: bears)
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    render(conv, "show.eex", bear: bear)
  end

  def delete(conv, _id) do
    %{conv | resp_body: "Delete a bear is Forbidden", status: 403}
  end
end

defmodule Servy.BearController do
  alias Servy.Wildthings

  def index(conv) do
    %{conv | resp_body: "<ul>#{Wildthings.get_bear_list()}</ul>", status: 200}
  end

  def show(conv, id) do
    %{conv | resp_body: Wildthings.bear_title(Wildthings.get_bear(id)), status: 200}
  end

  def delete(conv, _id) do
    %{conv | resp_body: "Delete a bear is Forbidden", status: 403}
  end
end

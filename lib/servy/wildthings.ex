defmodule Servy.Wildthings do
  alias Servy.Bear

  def bear_list do
    [
      %Bear{id: 1, name: "Baloo", type: "Grizzly", hibernating: true},
      %Bear{id: 2, name: "Boo", type: "Polar"},
      %Bear{id: 3, name: "Bungle", type: "Polar"},
      %Bear{id: 4, name: "Chester", type: "Black", hibernating: true},
      %Bear{id: 5, name: "Tooffe", type: "Grizzly"},
      %Bear{id: 6, name: "Tayra", type: "Black"},
      %Bear{id: 7, name: "Teddy", type: "Brown", hibernating: true},
      %Bear{id: 8, name: "Smokey", type: "Black"},
      %Bear{id: 9, name: "Paddington", type: "Brown"},
      %Bear{id: 10, name: "Scarface", type: "Grizzly", hibernating: true},
      %Bear{id: 11, name: "Snow", type: "Polar"},
      %Bear{id: 12, name: "Brutus", type: "Grizzly"},
      %Bear{id: 13, name: "Rosie", type: "Black", hibernating: true},
      %Bear{id: 14, name: "Roscoe", type: "Panda"},
      %Bear{id: 15, name: "Iceman", type: "Polar", hibernating: true},
      %Bear{id: 16, name: "Kenai", type: "Grizzly"}
    ]
  end

  def li_items(bear) do
    "<li>#{bear.id}: #{bear.name}</li>"
  end

  def get_bear_list() do
    bear_list() |> Enum.map(&li_items/1) |> Enum.join("")
  end

  def get_bear(id) when is_integer(id) do
    bear_list()
    |> Enum.find(fn bear -> bear.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id |> String.to_integer() |> get_bear
  end

  def bear_title(bear) do
    "<h1>Bear #{bear.id}: #{bear.name}</h1>"
  end
end

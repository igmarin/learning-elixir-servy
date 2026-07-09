defmodule Servy.Bear do
  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          type: String.t(),
          hibernating: boolean() | false
        }

  defstruct [:id, :name, :type, hibernating: false]
end

defmodule Recurse do
  def loopy([head | tail]) do
    IO.puts("Head: #{head} Tail: #{inspect(tail)}")
    loopy(tail)
  end

  def loopy([]), do: IO.puts("Done!")

  def factorial(n) when not is_integer(n), do: IO.puts("Is not an integer")
  def factorial(n) when is_integer(n) and n < 0, do: IO.puts("Not possible")
  def factorial(0), do: 1
  def factorial(n) when is_integer(n), do: Enum.reduce(1..n, 1, &*/2)
end

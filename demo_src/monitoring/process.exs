defmodule HelloProcess do
  # simple
  def print(msg) do
    IO.puts("#{inspect(self())}, #{msg}")
  end

  # loop
  def loop(n) when is_integer(n) and n > 0 do
    IO.puts("#{inspect(self())}, n = #{n}")

    # loop again in here
    loop(n - 1)
  end

  # exit loop condition
  def loop(_n) do
    IO.puts("#{inspect(self())}, exit.")
  end

  # state
  def state_n(n) do
    IO.puts("#{inspect(self())}, state: > 2")

    select_state(n - 1)
  end

  def state_2(n) do
    IO.puts("#{inspect(self())}, state: 2")

    select_state(n - 1)
  end

  def state_1(1) do
    IO.puts("#{inspect(self())}, state: 1 & exit")
  end

  def select_state(n) do
    IO.puts("#{inspect(self())}, select state: #{inspect(n)}")
    cond do
      n == 1 ->
        state_1(n)
      n == 2 ->
       state_2(n)
      true ->
       state_n(n)
    end
  end
end

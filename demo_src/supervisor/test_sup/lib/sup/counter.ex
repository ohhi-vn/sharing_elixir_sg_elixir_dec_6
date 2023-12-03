defmodule Sup.Counter do
  use GenServer

  def start_link(initial) do
    IO.puts("Counter start #{initial}")
    GenServer.start_link(__MODULE__, initial)
  end

  def inc(pid) do
    GenServer.call(pid, :inc)
  end

  def init(initial) do
    {:ok, initial}
  end

  def handle_call(:inc, _, count) do
    {:reply, count, count + 1}
  end
end

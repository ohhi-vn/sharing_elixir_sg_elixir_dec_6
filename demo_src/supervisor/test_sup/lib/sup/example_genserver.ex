defmodule Sup.ExampleGenserver do
  use GenServer

  def start_link(arg) do
    %{name: name} = arg
    GenServer.start_link(__MODULE__, arg, name: String.to_atom(name))
  end

  @impl true
  def init(state) do
    IO.puts("timer sleep 5 seconds when initializing! ")
    :timer.sleep(5000)
    send(self(), :finish)
    {:ok, state}
  end

  @impl true
  def handle_info(:finish, %{name: name} = state) do
    IO.puts("Hello from #{inspect(self())}, #{name}")
    {:noreply, state}
  end

end

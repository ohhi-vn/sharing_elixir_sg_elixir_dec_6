defmodule Sup.ExampleDynamicSupervisor do
  use DynamicSupervisor
  alias Sup.ExampleGenserver

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child_server(name) do
    spec = %{id: ExampleGenserver,
             start: {ExampleGenserver, :start_link, [%{name: name}]}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end

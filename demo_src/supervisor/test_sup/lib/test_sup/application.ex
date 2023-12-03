defmodule TestSup.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: TestSup.Worker.start_link(arg)
      # Bottleneck
      # {Sup.ExampleDynamicSupervisor, name: ExampleDynamicSupervisor},
      # No bottleneck
      {PartitionSupervisor, child_spec: DynamicSupervisor, name: Sup.ExamplePartitionupervisor},
      {DynamicSupervisor, name: Counter, strategy: :one_for_one}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TestSup.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

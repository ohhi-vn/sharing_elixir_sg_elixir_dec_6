# TestSup

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `test_sup` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:test_sup, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/test_sup>.

Intruction how to run ExampleDynamicSupervisor (Bottleneck)

``` elixir
# comment line 15th at application.ex
alias Sup.ExampleDynamicSupervisor
list = ["john", "alex", "peter"]
for name <- list do
  # The DynamicSupervisor starts a worker that sleeps for 5 seconds
  spawn(fn -> ExampleDynamicSupervisor.start_child_server(name) end)
end

Process.exit(Process.whereis(:john), :kill)
```

Intruction how to run ExamplePartitionupervisor (no Bottleneck)

``` elixir
# comment line 13rd at application.ex

alias Sup.ExamplePartitionupervisor
list = ["john", "alex", "peter"]
for name <- list do
  # The DynamicSupervisor starts a worker that sleeps for 5 seconds
  spawn(fn -> ExamplePartitionupervisor.start_child_server(name) end)
end
```
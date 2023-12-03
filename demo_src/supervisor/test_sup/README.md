# TestSup

## Run the command to go to the shell of app

```elixir
iex -S mix
```

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
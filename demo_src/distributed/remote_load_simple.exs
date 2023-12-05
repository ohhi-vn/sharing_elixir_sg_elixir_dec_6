# load code in remote load by Elixir's way
content = quote do
  defmodule DSpawn do
    def start() do
      for node <- Node.list do
        start(node)
      end
    end
    def start(node) do
      Node.spawn(node, fn ->
        IO.puts("#{inspect self()} node: #{inspect Node.self}")
        receive do
          {from, :ping} ->
            send(from, {:pong, {self(), Node.self}})
          {from, msg}  ->
            send(from, {:received, {self(), Node.self()}, msg})
          end
        end)
    end

    def start_link() do
      for node <- Node.list do
        start_link(node)
      end
    end
    def start_link(node) do
      Node.spawn_link(node, fn ->
        IO.puts("#{inspect self()} node: #{inspect Node.self}")
        receive do
          {from, :ping} ->
            send(from, {:pong, {self(), Node.self}})
          {from, msg}  ->
            send(from, {:received, {self(), Node.self()}, msg})
          end
        end)
    end

    def start_monitor() do
      for node <- Node.list do
        start_monitor(node)
      end
    end
    def start_monitor(node) do
      Node.spawn(node, fn ->
        IO.puts("#{inspect self()} node: #{inspect Node.self}")
        receive do
          {from, :ping} ->
            send(from, {:pong, {self(), Node.self}})
          {from, msg}  ->
            send(from, {:received, {self(), Node.self()}, msg})
          msg ->
            IO.puts "monitor: #{inspect msg}"

          end
        end)
    end

    def print_me() do
      IO.puts "#{inspect Node.self()}, #{inspect self()}, #{inspect __MODULE__}"
    end
  end
end

# Start n1 & n2 node by cmd:
#iex --sname n1@localhost --cookie abc
#iex --sname n2@localhost --cookie abc

Node.connect(:"n2@localhost")

# compile & load for local node
[{ DSpawn, object_code }] = Code.compile_quoted content

# check code is loaded or not
Code.loaded?(DSpawn)

# compile & load for remote node
:rpc.call(:n2@localhost, Code, :compile_quoted, [content])

# get pid from string.
:erlang.list_to_pid(String.to_charlist("<0.165.0>"))

{_module, binary, filename} = :code.get_object_code(module)
:rpc.call(Node, code, load_binary, [Module, Filename, Binary])

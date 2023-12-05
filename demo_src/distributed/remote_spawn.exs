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

    def remote_load_me() do
      {mod, bin, file} = :code.get_object_code(:"Elixir.DSpawn")
      for node <- Node.list do
        remote_load_mod(node, {mod, bin, file})
      end
    end

    def remote_load_mod(node, {mod, bin, file}) do
      :rpc.call(node, :code, :load_binary, [mod, file, bin])
    end

    def print_me() do
      IO.puts "#{inspect Node.self()}, #{inspect self()}, #{inspect __MODULE__}"
    end
  end
end

# compile & load for local node
[{ DSpawn, object_code }] = Code.compile_quoted content

# compile & load for remote node
:rpc.call(:n2@localhost, Code, :compile_quoted, [content])

# get pid from string.
:erlang.list_to_pid(String.to_charlist("<0.165.0>"))

# make module in runtime
module = Module.concat(MyProject, MyModule)
contents = Code.string_to_quoted!("def base(), do: IO.puts(\"test\")")
Module.create(module, contents, Macro.Env.location(__ENV__))

## demo for trap_exit

# loop fun
fun = fn me ->
  receive do
    :stop ->
      IO.puts("#{inspect(self())}, I'm out")

    {:trap, value} ->
      IO.puts("#{inspect(self())}, trap: #{inspect(value)}")
      Process.flag(:trap_exit, value)
      me.(me)

    :raise ->
      raise "#{inspect(self())}, raise a RuntimeError :D"

    {:spawn_link, name} ->
      pid = spawn_link(fn ->
        Process.register(self(), name)
        IO.puts("#{inspect(self())}, I'm a new process")
        me.(me)
      end)
      IO.puts("#{inspect(self())}, I'm spawn a new child: #{inspect(pid)}")

      me.(me)

    msg ->
      IO.puts(" #{inspect(self())}, unknown msg: #{inspect(msg)}")
      me.(me)
  end
end

# spawn a process
pid =
  spawn(fn ->
    IO.puts("my pid: #{inspect(self())}")
    fun.(fun)
  end)

# spawn a process with link
send(pid, {:spawn_link, :child_trap})

# turn on trap exit
send(pid, {:trap, true})

# raise an error in child process
send(:child_trap, :raise)


# test process is alive or not
IO.puts("#{inspect(pid)} is alive? =>  #{inspect(Process.alive?(pid))}")

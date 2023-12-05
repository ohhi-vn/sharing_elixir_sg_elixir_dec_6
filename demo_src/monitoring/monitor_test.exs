### Script test for minitoring process


# spawn monitor processes parent & son
MonitorProcess.create_parent()


# test child & parent is live or not
case Process.whereis(:parent_monitor) do
  nil ->
    IO.puts("parent process is death")

  pid ->
    result = Process.alive?(pid)
    IO.puts(" #{inspect(pid)} is alive? #{inspect(result)}")
end

case Process.whereis(:son_monitor) do
  nil ->
    IO.puts("son process is death")

  pid ->
    result = Process.alive?(pid)
    IO.puts(" #{inspect(pid)} is alive? #{inspect(result)}")
end

# Test by ping pong msg
send(:parent_monitor, {self(), :ping})
LetsCrash.get_one_msg()

send(:son_monitor, {self(), :ping})
LetsCrash.get_one_msg()


# test by raise error in son process
send(:son_monitor, :crash)

# send exit msg to both son and parent
spawn(fn -> send(:son_monitor, :shutdown) end)
spawn(fn -> send(:parent_monitor, :shutdown) end)

# kill processes by pid
Process.exit(:erlang.list_to_pid(String.to_charlist("<0.165.0>")), :kill)

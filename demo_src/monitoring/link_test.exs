## Linking processes run example ##

# kill processes
Process.exit(:erlang.list_to_pid(String.to_charlist("<0.165.0>")), :kill)
Process.exit(:erlang.list_to_pid(String.to_charlist("<0.165.0>")), :kill)


# spawn a couple of processes
LetsCrash.create_parent()

# test child & parent is live or not
case Process.whereis(:parent) do
  nil ->
    IO.puts("parent process is death")

  pid ->
    result = Process.alive?(pid)
    IO.puts(" #{inspect(pid)} is alive? #{inspect(result)}")
end

case Process.whereis(:son) do
  nil ->
    IO.puts("son process is death")

  pid ->
    result = Process.alive?(pid)
    IO.puts(" #{inspect(pid)} is alive? #{inspect(result)}")
end

# test by send ping pong msg
send(:parent, {self(), :ping})
LetsCrash.get_one_msg()

send(:son, {self(), :ping})
LetsCrash.get_one_msg()



# test by raise error in parent process
send(:parent, :crash)

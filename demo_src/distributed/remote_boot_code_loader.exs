# start the master node by command
# iex --sname master --cookie abc123 -S mix

:erl_boot_server.start([{127,0,0,1}])


# start the slave node by command
#  iex --sname worker --cookie abc123 --erl "-hosts 127.0.0.1 -id worker -loader inet"

# run on server
:rpc.call(:worker, :code, :add_paths, [:code.get_path])

# check by
Code.ensure_loaded(MyModule)

# get pid from string.
:erlang.list_to_pid(String.to_charlist("<0.165.0>"))

# module for child process
defmodule SimpleLoop do
  def loop() do
    receive do
      :stop ->
        :ok
      :raise ->
        raise "raised by #{inspect(self())}"
      {from, :ping} ->
        send(from, :pong)
        loop()
      msg ->
        IO.puts("#{inspect(self())}, Unknown msg: #{inspect(msg)}")
        loop()
    end
  end

  def init(name) do
    Process.register(self(), name)
    IO.puts("started child #{inspect(name)}, pid: #{inspect(self())}")

    loop()
  end
end

# start supervisor
MySup.start(
  :my_sup,
  [
    {SimpleLoop, :init, [:child_1]},
    {SimpleLoop, :init, [:child_2]}
  ],
  %{strategy: :group, restart: :failed}
)


# test child is alive or not

Process.alive?(Process.whereis(:child_1))

send(:child_1, {self(), :ping})

receive do
  msg -> IO.puts("#{inspect(msg)}")
after
  1000 ->
    IO.puts("no :pong return")
end


# make a crash in child process
send(:child_1, :raise)

# get pid of child process
Process.whereis(:child_1)
Process.whereis(:child_2)

defmodule MonitorProcess do
  def event_loop do
    receive do
      :crash ->
        IO.puts("#{inspect(self())}, I will raise a error!")
        raise "#{inspect(self())}, I'm out"

      :shutdown ->
        IO.puts("#{inspect(self())}, I'm shutting down...")

      {from, :ping} ->
        IO.puts("#{inspect(self())}, I got a ping msg from #{inspect(from)}")
        send(from, :pong)
        event_loop()

      msg ->
        IO.puts("#{inspect(self())}, Unknown msg: #{inspect(msg)}")
        event_loop()
    after
      3000 ->
        IO.puts("#{inspect(self())}, I'm fine")
        event_loop()
    end
  end

  def get_one_msg() do
    receive do
      msg ->
        IO.puts("#{inspect(self())}, got a msg: #{inspect(msg)}")
    end
  end

  def create_son do
    # spawn with monitor
    {pid, ref} = spawn_monitor(&event_loop/0)
    Process.register(pid, :son_monitor)

    IO.puts("spawn son process done => #{inspect(pid)}, ref: #{inspect(ref)}")
  end

  def init do
    create_son()

    event_loop()
  end

  def create_parent do
    # normal spawn
    pid = spawn(&init/0)
    Process.register(pid, :parent_monitor)
    IO.puts("spawn parent process done => #{inspect(pid)}")

    pid
  end
end

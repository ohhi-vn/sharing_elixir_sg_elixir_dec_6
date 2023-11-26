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
    end
  end

  def init(name) do
    Process.register(self(), name)
    IO.puts("started child #{inspect(name)}, pid: #{inspect(self())}")

    loop()
  end
end

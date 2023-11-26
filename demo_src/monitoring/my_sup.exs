defmodule MySup do
  ### API ###
  def start(name, childs, opts) when is_atom(name) and is_list(childs) and is_map(opts) do
    # start supervisor process.
    pid = spawn(__MODULE__, :init, [{name, childs, opts}])

    {:ok, pid}
  end

  def start_link(name, childs, opts) when is_atom(name) and is_list(childs) and is_map(opts) do
    # start supervisor process.
    pid = spawn_link(__MODULE__, :init, [{name, childs, opts}])

    {:ok, pid}
  end

  def stop(name) do
    send(name, {self(), :stop})

    receive do
      :stop_ok ->
        :ok
    end
  end

  ### Init function ###
  def init({name, children, _opts} = config) do
    Process.register(self(), name)
    Process.flag(:trap_exit, true)

    IO.puts("started supervisor with name #{inspect(name)}")

    result = start_children(children)
    IO.puts("Started #{inspect(map_size(result))}")

    # go to monitor stage
    sup_loop(result, config)
  end

  ### Private functions ###
  defp sup_loop(
         children,
         {name, child_param, %{strategy: strategy, restart: restart}} = config
       ) do
    receive do
      {from, :stop} ->
        IO.puts("stop supervisor: #{inspect(name)}")
        # stop all child by kill

        send(from, :stop_ok)

      # handle child down
      {:EXIT, pid, reason} ->
        IO.puts "Sup #{inspect(name)}, process die pid: #{inspect(pid)}, reason: #{inspect reason}"
        case strategy do
          :standalone ->
            case {restart, reason} do
              # doesn't restart child that force kill
              {:failed, :normal} ->
                IO.puts(
                  "Sup #{inspect(name)}, ignore normal shutdown, child pid: #{inspect(pid)}"
                )

                sup_loop(Map.delete(children, pid), config)

              # restart child
              _ ->
                {module, fun, args} = Map.get(children, pid)
                new_pid = spawn_link(module, fun, args)

                IO.puts(
                  "Sup #{inspect(name)}, strategy: #{inspect(strategy)}, restart child, child's old pid: #{inspect(pid)}, new pid: #{inspect(new_pid)}"
                )

                children =
                  children
                  |> Map.delete(pid)
                  |> Map.put(new_pid, {module, fun, args})

                sup_loop(children, config)
            end

          #
          :group when is_map_key(children, pid) ->
            IO.puts("Sup #{inspect(name)}, child in group died, restart all children now")

            for old_pid <- Map.keys(children) do
              Process.exit(old_pid, :kill)
            end

            children = start_children(child_param)

            sup_loop(children, config)
          _ ->
            sup_loop(children, config)
        end

      unknown ->
        IO.puts("unknown msg: #{inspect(unknown)}")
        sup_loop(children, config)
    end
  end

  defp start_children(childs) do
    start_children(childs, %{})
  end

  defp start_children([], result) do
    result
  end
  defp start_children([{module, fun, args} = child | rest], result) do
    pid = spawn_link(module, fun, args)
    IO.puts("started child #{inspect(pid)}")

    start_children(rest, Map.put(result, pid, child))
  end
end

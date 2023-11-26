defmodule MySup do
  ### API ###
  def start(name, childs, opts) when is_atom(name) and is_list(childs) and is_map(opts) do
    # start supervisor process.
    pid = spawn(__MODULE__, :init, [{name, childs, opts}])

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
  def init({name, children, opts} = config) do
    Process.register(self(), name)
    IO.puts("started supervisor with name #{inspect(name)}")

    result = start_children(children, opts)
    IO.puts("Started #{inspect(map_size(result))}")

    # go to monitor stage
    sup_loop(result, config)
  end

  ### Private functions ###
  defp sup_loop(
         children,
         {name, child_param, %{strategy: strategy, restart: restart} = opts} = config
       ) do
    receive do
      {from, :stop} ->
        IO.puts("stop supervisor: #{inspect(name)}")
        # stop all child by kill

        send(from, :stop_ok)

      # handle child down
      {:DOWN, ref, :process, pid, reason} ->
        IO.puts "Sup #{inspect(name)}, process die pid: #{inspect(pid)}, reason: #{inspect reason}"
        case strategy do
          :standalone ->
            case {restart, reason} do
              # doesn't restart child that force kill
              {:always, :kil} ->
                IO.puts(
                  "Sup #{inspect(name)}, strategy: #{inspect(strategy)}, ignore restart killed child, child pid: #{inspect(pid)}"
                )

                sup_loop(Map.delete(children, ref), config)

              # doesn't restart child that force kill
              {:failed, :normal} ->
                IO.puts(
                  "Sup #{inspect(name)}, strategy: #{inspect(strategy)}, ignore normal shutdown child, child pid: #{inspect(pid)}"
                )

                sup_loop(Map.delete(children, ref), config)

              # restart child
              _ ->
                {module, fun, args} = Map.get(children, ref)
                {new_pid, new_ref} = spawn_monitor(module, fun, args)

                IO.puts(
                  "Sup #{inspect(name)}, strategy: #{inspect(strategy)}, restart child, child's old pid: #{inspect(pid)}, new pid: #{inspect(new_pid)}"
                )

                children =
                  children
                  |> Map.delete(ref)
                  |> Map.put(new_ref, {module, fun, args})

                sup_loop(children, config)
            end

          #
          :group ->
            IO.puts("Sup #{inspect(name)}, group children die, restart now")
            children = start_children(child_param, opts)

            sup_loop(children, config)
        end

      unknown ->
        IO.puts("unknown msg: #{inspect(unknown)}")
        sup_loop(children, config)
    end
  end

  defp start_children(childs, %{strategy: :standalone} = opts) do
    start_children(childs, opts, %{})
  end

  defp start_children(childs, %{strategy: :group} = opts) do
    start_children(childs, opts, %{lastPid: nil})
  end

  defp start_children([], _opts, result) do
    result
  end

  # start child run standalone
  defp start_children(
         [{module, fun, args} = child | rest],
         %{strategy: :standalone} = opts,
         result
       ) do
    {_, ref} = spawn_monitor(module, fun, args)

    start_children(rest, opts, Map.put(result, ref, child))
  end

  # start child run in group. if one fail other will be restarted
  defp start_children([{module, fun, args}], %{strategy: :group} = opts, result) do
    # for group children, all will die together we need monitor one
    {_, ref} = spawn_monitor(module, fun, args)

    start_children([], opts, Map.put(result, :group, ref))
  end

  defp start_children([child | rest], %{strategy: :group} = opts, %{lastPid: lastPid} = result) do
    pid = spawn(fn -> spawn_child_link(lastPid, child) end)

    start_children(rest, opts, Map.put(result, :lastPid, pid))
  end

  # support link a chain
  defp spawn_child_link(lastPid, {module, fun, args}) do
    if lastPid != nil do
      Process.link(lastPid)
    end

    apply(module, fun, args)
  end
end

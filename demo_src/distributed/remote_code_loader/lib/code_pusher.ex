defmodule RemoteCodeLoader.Pusher do

  def generate_code(module, str_code) do
    contents = Code.string_to_quoted!(str_code)
    Module.create(module, contents, Macro.Env.location(__ENV__))
  end


  def generate_simple do
    generate_code(Simple,
    """
    def print_me do
      IO.puts "#{inspect Node.self()} - #{inspect self()}, Hello!"
    end
    """)
  end

  def push_to_remote_simple(node) do
    {:module, name, binary, _other} = generate_simple()

    :rpc.call(node, :code, :load_binary, [name, 'Filename', binary])
  end

  def push_to_remote(node, module_name, file) do
    {:ok, contents} = File.read(file)

    {:module, name, binary, _other} = generate_code(module_name, contents)
    :rpc.call(node, :code, :load_binary, [name, 'Filename', binary])
  end

  def push_to_all_remotes(module_name, file) do
    {:ok, contents} = File.read(file)

    {:module, name, binary, _other} = generate_code(module_name, contents)

    :rpc.multicall(:code, :load_binary, [name, 'Filename', binary])
  end

  def push_to_remote_str(node, module_name, str) do
    {:module, name, binary, _other} = generate_code(module_name, str)
    :rpc.call(node, :code, :load_binary, [name, 'Filename', binary])
  end

  def push_to_all_remotes_str(module_name, str) do
    {:module, name, binary, _other} = generate_code(module_name, str)

    :rpc.multicall(:code, :load_binary, [name, 'Filename', binary])
  end
end

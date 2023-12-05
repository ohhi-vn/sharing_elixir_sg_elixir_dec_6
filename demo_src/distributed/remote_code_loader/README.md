# RemoteCodeLoader

## Introduce

## Guide

Run a remote node with simple command (without app):

```bash
iex --sname n2@localhost --cookie abc
```

Run app with Elixir's shell by command:

```bash
iex --sname n1@localhost --cookie abc -S mix
```

Connect to n2 node from Shell:

```Elixir
Node.connect(:n2@localhost)
```

Test deploy code to n2 node by command:

```Elixir
RemoteCodeLoader.Pusher.push_to_remote_simple
```

Test deploy a file to all nodes:

```Elixir
RemoteCodeLoader.Pusher.push_to_all_remotes(Hehe, "test_code.txt")
```

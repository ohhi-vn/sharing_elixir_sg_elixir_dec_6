defmodule RemoteCodeLoaderTest do
  use ExUnit.Case
  doctest RemoteCodeLoader

  test "greets the world" do
    assert RemoteCodeLoader.hello() == :world
  end
end

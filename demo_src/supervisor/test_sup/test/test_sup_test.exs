defmodule TestSupTest do
  use ExUnit.Case
  doctest TestSup

  test "greets the world" do
    assert TestSup.hello() == :world
  end
end

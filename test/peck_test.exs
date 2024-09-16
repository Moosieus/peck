defmodule PeckTest do
  use ExUnit.Case
  doctest Peck

  test "greets the world" do
    assert Peck.hello() == :world
  end
end

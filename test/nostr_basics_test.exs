defmodule NostrBasicsTest do
  use ExUnit.Case
  doctest NostrBasics

  test "greets the world" do
    assert NostrBasics.hello() == :world
  end
end

defmodule NatsTest do
  use ExUnit.Case
  doctest Nats

  test "greets the world" do
    assert Nats.hello() == :world
  end
end

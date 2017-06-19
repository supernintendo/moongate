defmodule Moongate.CoreTest do
  use ExUnit.Case
  alias Moongate.Core
  doctest Moongate.Core

  test "&atlas/0" do
    atlas = Core.atlas()

    assert atlas.ip
    assert atlas.rings
    assert atlas.rings["Entity"]
    assert atlas.rings["Entity"].__index__ == "Integer"
    assert atlas.rings["Entity"].__origin_id__ == "String"
    assert atlas.rings["Entity"].float == "Float"
    assert atlas.rings["Entity"].int == "Integer"
    assert atlas.rings["Entity"].string == "String"
  end

  test "&dispatch/1" do
  end

  test "&game/0" do
    assert Core.game() == "Test"
  end

  test "&log/1" do
  end

  test "&log/2" do
  end

  test "&module/0" do
    assert Core.module() == Test.Game
  end

  test "&module/1" do
    assert Core.module("Board") == Test.Board
    assert Core.module("Entity") == Test.Entity
    refute Core.module("foo")
  end

  test "&pid/1" do
  end

  test "&trigger/2" do
  end

  test "&trigger/3" do
  end

  test "&uuid/1" do
    results =
      0..1_000
      |> Enum.map(fn _ -> Core.uuid("test") end)

    assert results == Enum.uniq(results)
  end
end

defmodule Moongate.Tests.Core do
  use ExUnit.Case, async: true
  alias Moongate.Core

  test "&atom_to_string/2" do
    assert Core.atom_to_string(:foo) == "foo"
    assert Core.atom_to_string(Foo) == "Foo"
  end

  test "&camelize/1" do
    assert Core.camelize("foo_bar") == "FooBar"
    assert Core.camelize("foo-bar") == "FooBar"
  end

  test "&deed_module/1" do
    assert Core.deed_module("TestDeed") == Test.Deed.TestDeed
  end

  test "&handshake/0" do
    handshake = Core.handshake

    assert Map.has_key?(handshake, :ip)
    assert Map.has_key?(handshake, :rings)
    assert Map.has_key?(handshake.rings, "TestRing")
    assert Map.has_key?(handshake.rings["TestRing"], :origin)
    assert Map.has_key?(handshake.rings["TestRing"], :test_attr)
    assert handshake.rings["TestRing"].origin == :origin
    assert handshake.rings["TestRing"].test_attr == :float
  end

  test "&has_function/2" do
    assert Core.has_function?(Core, "handshake")
    refute Core.has_function?(Core, "nonexistent_function")
  end

  test "&module_to_string/2" do
    assert Core.module_to_string(Core) == "Moongate.Core"
  end

  test "&world_apply/1" do
    assert Core.world_apply(:world_apply_helper) == "It worked!"
  end

  test "&world_apply/2" do
    arg = 42

    assert Core.world_apply(arg, :world_apply_helper) == {"It worked!", arg}
    assert Core.world_apply([arg], :world_apply_helper) == {"It worked!", arg}
  end

  test "&world_directory/1" do
    assert Core.world_directory == "worlds/test"
  end

  test "&world_module/0" do
    assert Core.world_module == Test.World
  end

  test "&world_name/0" do
    assert Core.world_name == "test"
  end
end
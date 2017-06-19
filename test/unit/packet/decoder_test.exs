defmodule Moongate.PacketDecoderTest do
  use ExUnit.Case
  alias Moongate.{
    PacketDecoder
  }

  setup_all do
    tokens = Moongate.PacketCompressor.by_word()

    {:ok,
      handler_token: tokens["echo"],
      ring_token: tokens["Entity"],
      rule_token: tokens["Modify"],
      zone_token: tokens["Board"]
    }
  end

  test "&decode/1 with body", context do
    r = PacketDecoder.decode("#::hello world")
    r_2 = PacketDecoder.decode("#[#{context.handler_token}]::hello world")
    r_3 = PacketDecoder.decode("#(#{context.zone_token}:$)::hello world")
    r_4 = PacketDecoder.decode("#(#{context.zone_token}:test)::hello world")
    r_5 = PacketDecoder.decode("#\{#{context.ring_token}}::hello world")
    r_6 = PacketDecoder.decode("#<#{context.rule_token}>::hello world")

    assert r.body == "hello world"
    assert r_2.body == "hello world"
    assert r_2.handler == :echo
    assert r_3.body == "hello world"
    assert r_3.zone == {Board, "$"}
    assert r_4.body == "hello world"
    assert r_4.zone == {Board, "test"}
    assert r_5.body == "hello world"
    assert r_5.ring == Entity
    assert r_6.body == "hello world"
    assert r_6.rule == Modify
  end

  test "&decode/1 with zone", context do
    zone = context.zone_token
    r = PacketDecoder.decode("#(#{zone}:test)")
    r_2 = PacketDecoder.decode("#(#{zone}:$)")
    r_3 = PacketDecoder.decode("#(#{zone}:test)::hello world")
    r_4 = PacketDecoder.decode("#(#{zone}:$)::hello world")
    r_5 = PacketDecoder.decode("#(#{zone}:test)[#{context.handler_token}]")
    r_6 = PacketDecoder.decode("#(#{zone}:$)[#{context.handler_token}]")
    r_7 = PacketDecoder.decode("#(#{zone}:test){#{context.ring_token}}")
    r_8 = PacketDecoder.decode("#(#{zone}:$){#{context.ring_token}}")
    r_9 = PacketDecoder.decode("#(#{zone}:test)<#{context.rule_token}>")
    r_10 = PacketDecoder.decode("#(#{zone}:$)<#{context.rule_token}>")

    assert r.zone == {Board, "test"}
    assert r_2.zone == {Board, "$"}
    assert r_3.zone == {Board, "test"}
    assert r_3.body == "hello world"
    assert r_4.zone == {Board, "$"}
    assert r_4.body == "hello world"
    assert r_5.zone == {Board, "test"}
    assert r_5.handler == :echo
    assert r_6.zone == {Board, "$"}
    assert r_6.handler == :echo
    assert r_7.zone == {Board, "test"}
    assert r_7.ring == Entity
    assert r_8.zone == {Board, "$"}
    assert r_8.ring == Entity
    assert r_9.zone == {Board, "test"}
    assert r_9.rule == Modify
    assert r_10.zone == {Board, "$"}
    assert r_10.rule == Modify
  end

  test "&decode/1 with uncompressed zone", context do
    r = PacketDecoder.decode("#(FooBar:test)")
    r_2 = PacketDecoder.decode("#(FooBar:$)")
    r_3 = PacketDecoder.decode("#(FooBar:test)::hello world")
    r_4 = PacketDecoder.decode("#(FooBar:$)::hello world")
    r_5 = PacketDecoder.decode("#(FooBar:test)[#{context.handler_token}]")
    r_6 = PacketDecoder.decode("#(FooBar:$)[#{context.handler_token}]")
    r_7 = PacketDecoder.decode("#(FooBar:test){#{context.ring_token}}")
    r_8 = PacketDecoder.decode("#(FooBar:$){#{context.ring_token}}")
    r_9 = PacketDecoder.decode("#(FooBar:test)<#{context.rule_token}>")
    r_10 = PacketDecoder.decode("#(FooBar:$)<#{context.rule_token}>")

    assert r.zone == {"FooBar", "test"}
    assert r_2.zone == {"FooBar", "$"}
    assert r_3.zone == {"FooBar", "test"}
    assert r_3.body == "hello world"
    assert r_4.zone == {"FooBar", "$"}
    assert r_4.body == "hello world"
    assert r_5.zone == {"FooBar", "test"}
    assert r_5.handler == :echo
    assert r_6.zone == {"FooBar", "$"}
    assert r_6.handler == :echo
    assert r_7.zone == {"FooBar", "test"}
    assert r_7.ring == Entity
    assert r_8.zone == {"FooBar", "$"}
    assert r_8.ring == Entity
    assert r_9.zone == {"FooBar", "test"}
    assert r_9.rule == Modify
    assert r_10.zone == {"FooBar", "$"}
    assert r_10.rule == Modify
  end

  test "&decode/1 with ring", context do
    ring = context.ring_token
    r = PacketDecoder.decode("\#{#{ring}}")
    r_2 = PacketDecoder.decode("#(#{context.zone_token}:$){#{ring}}")
    r_3 = PacketDecoder.decode("#(#{context.zone_token}:test){#{ring}}")
    r_4 = PacketDecoder.decode("\#{#{ring}}::hello world")
    r_5 = PacketDecoder.decode("\#{#{ring}}[#{context.handler_token}]")
    r_6 = PacketDecoder.decode("\#{#{ring}}<#{context.rule_token}>")

    assert r.ring == Entity
    assert r_2.ring == Entity
    assert r_2.zone == {Board, "$"}
    assert r_3.ring == Entity
    assert r_3.zone == {Board, "test"}
    assert r_4.ring == Entity
    assert r_4.body == "hello world"
    assert r_5.ring == Entity
    assert r_5.handler == :echo
    assert r_6.ring == Entity
    assert r_6.rule == Modify
  end

  test "&decode/1 with uncompressed ring", context do
    r = PacketDecoder.decode("\#{BazQux}")
    r_2 = PacketDecoder.decode("#(#{context.zone_token}:$){BazQux}")
    r_3 = PacketDecoder.decode("#(#{context.zone_token}:test){BazQux}")
    r_4 = PacketDecoder.decode("\#{BazQux}::hello world")
    r_5 = PacketDecoder.decode("\#{BazQux}[#{context.handler_token}]")
    r_6 = PacketDecoder.decode("\#{BazQux}<#{context.rule_token}>")

    assert r.ring == "BazQux"
    assert r_2.ring == "BazQux"
    assert r_2.zone == {Board, "$"}
    assert r_3.ring == "BazQux"
    assert r_3.zone == {Board, "test"}
    assert r_4.ring == "BazQux"
    assert r_4.body == "hello world"
    assert r_5.ring == "BazQux"
    assert r_5.handler == :echo
    assert r_6.ring == "BazQux"
    assert r_6.rule == Modify
  end

  test "&decode/1 with rule", context do
    rule = context.rule_token
    r = PacketDecoder.decode("#<#{rule}>")
    r_2 = PacketDecoder.decode("#(#{context.zone_token}:$)<#{rule}>")
    r_3 = PacketDecoder.decode("#(#{context.zone_token}:test)<#{rule}>")
    r_4 = PacketDecoder.decode("\#{#{context.ring_token}}<#{rule}>")
    r_5 = PacketDecoder.decode("#<#{rule}>::hello world")
    r_6 = PacketDecoder.decode("#<#{rule}>[#{context.handler_token}]")

    assert r.rule == Modify
    assert r_2.rule == Modify
    assert r_2.zone == {Board, "$"}
    assert r_3.rule == Modify
    assert r_3.zone == {Board, "test"}
    assert r_4.rule == Modify
    assert r_4.ring == Entity
    assert r_5.rule == Modify
    assert r_5.body == "hello world"
    assert r_6.rule == Modify
    assert r_6.handler == :echo
  end

  test "&decode/1 with uncompressed rule", context do
    r = PacketDecoder.decode("#<QuuxQuuz>")
    r_2 = PacketDecoder.decode("#(#{context.zone_token}:$)<QuuxQuuz>")
    r_3 = PacketDecoder.decode("#(#{context.zone_token}:test)<QuuxQuuz>")
    r_4 = PacketDecoder.decode("\#{#{context.ring_token}}<QuuxQuuz>")
    r_5 = PacketDecoder.decode("#<QuuxQuuz>::hello world")
    r_6 = PacketDecoder.decode("#<QuuxQuuz>[#{context.handler_token}]")

    assert r.rule == "QuuxQuuz"
    assert r_2.rule == "QuuxQuuz"
    assert r_2.zone == {Board, "$"}
    assert r_3.rule == "QuuxQuuz"
    assert r_3.zone == {Board, "test"}
    assert r_4.rule == "QuuxQuuz"
    assert r_4.ring == Entity
    assert r_5.rule == "QuuxQuuz"
    assert r_5.body == "hello world"
    assert r_6.rule == "QuuxQuuz"
    assert r_6.handler == :echo
  end

  test "&decode/1 with handler", context do
    handler = context.handler_token
    r = PacketDecoder.decode("#[#{handler}]")
    r_2 = PacketDecoder.decode("#(#{context.zone_token}:$)[#{handler}]")
    r_3 = PacketDecoder.decode("#(#{context.zone_token}:test)[#{handler}]")
    r_4 = PacketDecoder.decode("\#{#{context.ring_token}}[#{handler}]")
    r_5 = PacketDecoder.decode("#[#{handler}]::hello world")
    r_6 = PacketDecoder.decode("#<#{context.rule_token}>[#{handler}]")

    assert r.handler == :echo
    assert r_2.handler == :echo
    assert r_2.zone == {Board, "$"}
    assert r_3.handler == :echo
    assert r_3.zone == {Board, "test"}
    assert r_4.handler == :echo
    assert r_4.ring == Entity
    assert r_5.handler == :echo
    assert r_5.body == "hello world"
    assert r_6.handler == :echo
    assert r_6.rule == Modify
  end

  test "&decode/1 with uncompressed handler", context do
    r = PacketDecoder.decode("#[custom_func]")
    r_2 = PacketDecoder.decode("#(#{context.zone_token}:$)[custom_func]")
    r_3 = PacketDecoder.decode("#(#{context.zone_token}:test)[custom_func]")
    r_4 = PacketDecoder.decode("\#{#{context.ring_token}}[custom_func]")
    r_5 = PacketDecoder.decode("#[custom_func]::hello world")
    r_6 = PacketDecoder.decode("#<#{context.rule_token}>[custom_func]")

    assert r.handler == "custom_func"
    assert r_2.handler == "custom_func"
    assert r_2.zone == {Board, "$"}
    assert r_3.handler == "custom_func"
    assert r_3.zone == {Board, "test"}
    assert r_4.handler == "custom_func"
    assert r_4.ring == Entity
    assert r_5.handler == "custom_func"
    assert r_5.body == "hello world"
    assert r_6.handler == "custom_func"
    assert r_6.rule == Modify
  end

  test "&decode/1 with various fields", context do
    zone = context.zone_token
    ring = context.ring_token
    rule = context.rule_token
    handler = context.handler_token

    r = PacketDecoder.decode("#(#{zone}:test){#{ring}}[#{handler}]::hello world")
    r_2 = PacketDecoder.decode("#(#{zone}:$){#{ring}}[#{handler}]::hello world")
    r_3 = PacketDecoder.decode("#(FooBar:test){#{ring}}<#{rule}>[#{handler}]::hello world")
    r_4 = PacketDecoder.decode("#(FooBar:$){#{ring}}<#{rule}>[#{handler}]::hello world")
    r_5 = PacketDecoder.decode("#(#{zone}:test){BazQux}[#{handler}]::hello world")
    r_6 = PacketDecoder.decode("#(#{zone}:$){BazQux}[#{handler}]::hello world")
    r_7 = PacketDecoder.decode("#(FooBar:test){BazQux}<#{rule}>[#{handler}]::hello world")
    r_8 = PacketDecoder.decode("#(FooBar:test){BazQux}<#{rule}>[custom_func]::hello world")
    r_9 = PacketDecoder.decode("#(FooBar:test){#{ring}}<QuuxQuuz>[#{handler}]::hello world")
    r_10 = PacketDecoder.decode("#(FooBar:test){#{ring}}<QuuxQuuz>[custom_func]::hello world")
    r_11 = PacketDecoder.decode("#(FooBar:test){BazQux}<QuuxQuuz>[#{handler}]::hello world")
    r_12 = PacketDecoder.decode("#(FooBar:test){BazQux}<QuuxQuuz>[custom_func]::hello world")
    r_13 = PacketDecoder.decode("#(FooBar:$){BazQux}<#{rule}>[#{handler}]::hello world")
    r_14 = PacketDecoder.decode("#(FooBar:$){BazQux}<#{rule}>[custom_func]::hello world")
    r_15 = PacketDecoder.decode("#(FooBar:$){#{ring}}<QuuxQuuz>[#{handler}]::hello world")
    r_16 = PacketDecoder.decode("#(FooBar:$){#{ring}}<QuuxQuuz>[custom_func]::hello world")
    r_17 = PacketDecoder.decode("#(FooBar:$){BazQux}<QuuxQuuz>[#{handler}]::hello world")
    r_18 = PacketDecoder.decode("#(FooBar:$){BazQux}<QuuxQuuz>[custom_func]::hello world")

    assert r == %{
      body: "hello world",
      handler: :echo,
      ring: Entity,
      rule: nil,
      zone: {Board, "test"}
    }
    assert r_2 == %{
      body: "hello world",
      handler: :echo,
      ring: Entity,
      rule: nil,
      zone: {Board, "$"}
    }
    assert r_3 == %{
      body: "hello world",
      handler: :echo,
      ring: Entity,
      rule: Modify,
      zone: {"FooBar", "test"}
    }
    assert r_4 == %{
      body: "hello world",
      handler: :echo,
      ring: Entity,
      rule: Modify,
      zone: {"FooBar", "$"}
    }
    assert r_5 == %{
      body: "hello world",
      handler: :echo,
      ring: "BazQux",
      rule: nil,
      zone: {Board, "test"}
    }
    assert r_6 == %{
      body: "hello world",
      handler: :echo,
      ring: "BazQux",
      rule: nil,
      zone: {Board, "$"}
    }
    assert r_7 == %{
      body: "hello world",
      handler: :echo,
      ring: "BazQux",
      rule: Modify,
      zone: {"FooBar", "test"}
    }
    assert r_8 == %{
      body: "hello world",
      handler: "custom_func",
      ring: "BazQux",
      rule: Modify,
      zone: {"FooBar", "test"}
    }
    assert r_9 == %{
      body: "hello world",
      handler: :echo,
      ring: Entity,
      rule: "QuuxQuuz",
      zone: {"FooBar", "test"}
    }
    assert r_10 == %{
      body: "hello world",
      handler: "custom_func",
      ring: Entity,
      rule: "QuuxQuuz",
      zone: {"FooBar", "test"}
    }
    assert r_11 == %{
      body: "hello world",
      handler: :echo,
      ring: "BazQux",
      rule: "QuuxQuuz",
      zone: {"FooBar", "test"}
    }
    assert r_12 == %{
      body: "hello world",
      handler: "custom_func",
      ring: "BazQux",
      rule: "QuuxQuuz",
      zone: {"FooBar", "test"}
    }
    assert r_13 == %{
      body: "hello world",
      handler: :echo,
      ring: "BazQux",
      rule: Modify,
      zone: {"FooBar", "$"}
    }
    assert r_14 == %{
      body: "hello world",
      handler: "custom_func",
      ring: "BazQux",
      rule: Modify,
      zone: {"FooBar", "$"}
    }
    assert r_15 == %{
      body: "hello world",
      handler: :echo,
      ring: Entity,
      rule: "QuuxQuuz",
      zone: {"FooBar", "$"}
    }
    assert r_16 == %{
      body: "hello world",
      handler: "custom_func",
      ring: Entity,
      rule: "QuuxQuuz",
      zone: {"FooBar", "$"}
    }
    assert r_17 == %{
      body: "hello world",
      handler: :echo,
      ring: "BazQux", rule: "QuuxQuuz",
      zone: {"FooBar", "$"}
    }
    assert r_18 == %{
      body: "hello world",
      handler: "custom_func",
      ring: "BazQux",
      rule: "QuuxQuuz",
      zone: {"FooBar", "$"}
    }
  end
end

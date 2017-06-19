defmodule Moongate.PacketEncoderTest do
  use ExUnit.Case
  alias Moongate.{
    CorePacket,
    PacketEncoder
  }

  @body {:body, "hello world"}
  @handler {:handler, "echo"}
  @uc_handler {:handler, "custom_func"}
  @zone {:zone, {Board, "test"}}
  @uc_zone {:zone, {FooBar, "test"}}
  @zone_default {:zone, Board}
  @uc_zone_default {:zone, FooBar}
  @ring {:ring, Entity}
  @uc_ring {:ring, BazQux}
  @rule {:rule, Modify}
  @uc_rule {:rule, QuuxQuuz}

  setup_all do
    tokens = Moongate.PacketCompressor.by_word()

    {:ok,
      handler_token: tokens["echo"],
      ring_token: tokens["Entity"],
      rule_token: tokens["Modify"],
      zone_token: tokens["Board"]
    }
  end

  defp packet(chunks) do
    struct(%CorePacket{}, Enum.into(chunks, %{}))
  end

  test "&encode/1 with body", context do
    r = PacketEncoder.encode(packet([@body]))
    r_2 = PacketEncoder.encode(packet([@body, @handler]))
    r_3 = PacketEncoder.encode(packet([@body, @zone]))
    r_4 = PacketEncoder.encode(packet([@body, @zone_default]))
    r_5 = PacketEncoder.encode(packet([@body, @ring]))
    r_6 = PacketEncoder.encode(packet([@body, @rule]))

    assert r == "#::hello world"
    assert r_2 == "#[#{context.handler_token}]::hello world"
    assert r_3 == "#(#{context.zone_token}:test)::hello world"
    assert r_4 == "#(#{context.zone_token}:$)::hello world"
    assert r_5 == "#\{#{context.ring_token}}::hello world"
    assert r_6 == "#<#{context.rule_token}>::hello world"
  end

  test "&encode/1 with zone", context do
    zone = context.zone_token
    r = PacketEncoder.encode(packet([@zone]))
    r_2 = PacketEncoder.encode(packet([@zone_default]))
    r_3 = PacketEncoder.encode(packet([@zone, @body]))
    r_4 = PacketEncoder.encode(packet([@zone_default, @body]))
    r_5 = PacketEncoder.encode(packet([@zone, @handler]))
    r_6 = PacketEncoder.encode(packet([@zone_default, @handler]))
    r_7 = PacketEncoder.encode(packet([@zone, @ring]))
    r_8 = PacketEncoder.encode(packet([@zone_default, @ring]))
    r_9 = PacketEncoder.encode(packet([@zone, @rule]))
    r_10 = PacketEncoder.encode(packet([@zone_default, @rule]))

    assert r == "#(#{zone}:test)"
    assert r_2 == "#(#{zone}:$)"
    assert r_3 == "#(#{zone}:test)::hello world"
    assert r_4 == "#(#{zone}:$)::hello world"
    assert r_5 == "#(#{zone}:test)[#{context.handler_token}]"
    assert r_6 == "#(#{zone}:$)[#{context.handler_token}]"
    assert r_7 == "#(#{zone}:test){#{context.ring_token}}"
    assert r_8 == "#(#{zone}:$){#{context.ring_token}}"
    assert r_9 == "#(#{zone}:test)<#{context.rule_token}>"
    assert r_10 == "#(#{zone}:$)<#{context.rule_token}>"
  end

  test "&encode/1 with uncompressed zone", context do
    r = PacketEncoder.encode(packet([@uc_zone]))
    r_2 = PacketEncoder.encode(packet([@uc_zone_default]))
    r_3 = PacketEncoder.encode(packet([@uc_zone, @body]))
    r_4 = PacketEncoder.encode(packet([@uc_zone_default, @body]))
    r_5 = PacketEncoder.encode(packet([@uc_zone, @handler]))
    r_6 = PacketEncoder.encode(packet([@uc_zone_default, @handler]))
    r_7 = PacketEncoder.encode(packet([@uc_zone, @ring]))
    r_8 = PacketEncoder.encode(packet([@uc_zone_default, @ring]))
    r_9 = PacketEncoder.encode(packet([@uc_zone, @rule]))
    r_10 = PacketEncoder.encode(packet([@uc_zone_default, @rule]))

    assert r == "#(FooBar:test)"
    assert r_2 == "#(FooBar:$)"
    assert r_3 == "#(FooBar:test)::hello world"
    assert r_4 == "#(FooBar:$)::hello world"
    assert r_5 == "#(FooBar:test)[#{context.handler_token}]"
    assert r_6 == "#(FooBar:$)[#{context.handler_token}]"
    assert r_7 == "#(FooBar:test){#{context.ring_token}}"
    assert r_8 == "#(FooBar:$){#{context.ring_token}}"
    assert r_9 == "#(FooBar:test)<#{context.rule_token}>"
    assert r_10 == "#(FooBar:$)<#{context.rule_token}>"
  end

  test "&encode/1 with ring", context do
    ring = context.ring_token
    r = PacketEncoder.encode(packet([@ring]))
    r_2 = PacketEncoder.encode(packet([@ring, @zone]))
    r_3 = PacketEncoder.encode(packet([@ring, @body]))
    r_4 = PacketEncoder.encode(packet([@ring, @handler]))
    r_5 = PacketEncoder.encode(packet([@ring, @rule]))

    assert r == "\#{#{ring}}"
    assert r_2 == "#(#{context.zone_token}:test){#{ring}}"
    assert r_3 == "\#{#{ring}}::hello world"
    assert r_4 == "\#{#{ring}}[#{context.handler_token}]"
    assert r_5 == "\#{#{ring}}<#{context.rule_token}>"
  end

  test "&encode/1 with uncompressed ring", context do
    r = PacketEncoder.encode(packet([@uc_ring]))
    r_2 = PacketEncoder.encode(packet([@uc_ring, @zone]))
    r_3 = PacketEncoder.encode(packet([@uc_ring, @body]))
    r_4 = PacketEncoder.encode(packet([@uc_ring, @handler]))
    r_5 = PacketEncoder.encode(packet([@uc_ring, @rule]))

    assert r == "\#{BazQux}"
    assert r_2 == "#(#{context.zone_token}:test){BazQux}"
    assert r_3 == "\#{BazQux}::hello world"
    assert r_4 == "\#{BazQux}[#{context.handler_token}]"
    assert r_5 == "\#{BazQux}<#{context.rule_token}>"
  end

  test "&encode/1 with rule", context do
    rule = context.rule_token
    r = PacketEncoder.encode(packet([@rule]))
    r_2 = PacketEncoder.encode(packet([@rule, @zone]))
    r_3 = PacketEncoder.encode(packet([@rule, @ring]))
    r_4 = PacketEncoder.encode(packet([@rule, @body]))
    r_5 = PacketEncoder.encode(packet([@rule, @handler]))

    assert r == "#<#{rule}>"
    assert r_2 == "#(#{context.zone_token}:test)<#{rule}>"
    assert r_3 == "\#{#{context.ring_token}}<#{rule}>"
    assert r_4 == "#<#{rule}>::hello world"
    assert r_5 == "#<#{rule}>[#{context.handler_token}]"
  end

  test "&encode/1 with uncompressed rule", context do
    r = PacketEncoder.encode(packet([@uc_rule]))
    r_2 = PacketEncoder.encode(packet([@uc_rule, @zone]))
    r_3 = PacketEncoder.encode(packet([@uc_rule, @ring]))
    r_4 = PacketEncoder.encode(packet([@uc_rule, @body]))
    r_5 = PacketEncoder.encode(packet([@uc_rule, @handler]))

    assert r == "#<QuuxQuuz>"
    assert r_2 == "#(#{context.zone_token}:test)<QuuxQuuz>"
    assert r_3 == "\#{#{context.ring_token}}<QuuxQuuz>"
    assert r_4 == "#<QuuxQuuz>::hello world"
    assert r_5 == "#<QuuxQuuz>[#{context.handler_token}]"
  end

  test "&encode/1 with handler", context do
    handler = context.handler_token
    r = PacketEncoder.encode(packet([@handler]))
    r_2 = PacketEncoder.encode(packet([@handler, @zone]))
    r_3 = PacketEncoder.encode(packet([@handler, @ring]))
    r_4 = PacketEncoder.encode(packet([@handler, @body]))
    r_5 = PacketEncoder.encode(packet([@handler, @rule]))

    assert r == "#[#{handler}]"
    assert r_2 == "#(#{context.zone_token}:test)[#{handler}]"
    assert r_3 == "\#{#{context.ring_token}}[#{handler}]"
    assert r_4 == "#[#{handler}]::hello world"
    assert r_5 == "#<#{context.rule_token}>[#{handler}]"
  end

  test "&encode/1 with uncompressed handler", context do
    r = PacketEncoder.encode(packet([@uc_handler]))
    r_2 = PacketEncoder.encode(packet([@uc_handler, @zone]))
    r_3 = PacketEncoder.encode(packet([@uc_handler, @ring]))
    r_4 = PacketEncoder.encode(packet([@uc_handler, @body]))
    r_5 = PacketEncoder.encode(packet([@uc_handler, @rule]))

    assert r == "#[custom_func]"
    assert r_2 == "#(#{context.zone_token}:test)[custom_func]"
    assert r_3 == "\#{#{context.ring_token}}[custom_func]"
    assert r_4 == "#[custom_func]::hello world"
    assert r_5 == "#<#{context.rule_token}>[custom_func]"
  end

  test "&encode/1 with various fields", context do
    zone = context.zone_token
    ring = context.ring_token
    rule = context.rule_token
    handler = context.handler_token

    r = PacketEncoder.encode(packet([@body, @zone, @ring, @handler]))
    r_2 = PacketEncoder.encode(packet([@body, @zone_default, @ring, @handler]))
    r_3 = PacketEncoder.encode(packet([@body, @uc_zone, @ring, @rule, @handler]))
    r_4 = PacketEncoder.encode(packet([@body, @uc_zone_default, @ring, @rule, @handler]))
    r_5 = PacketEncoder.encode(packet([@body, @zone, @uc_ring, @handler]))
    r_6 = PacketEncoder.encode(packet([@body, @zone_default, @uc_ring, @handler]))
    r_7 = PacketEncoder.encode(packet([@body, @uc_zone, @uc_ring, @rule, @handler]))
    r_8 = PacketEncoder.encode(packet([@body, @uc_zone, @uc_ring, @rule, @uc_handler]))
    r_9 = PacketEncoder.encode(packet([@body, @uc_zone, @ring, @uc_rule, @handler]))
    r_10 = PacketEncoder.encode(packet([@body, @uc_zone, @ring, @uc_rule, @uc_handler]))
    r_11 = PacketEncoder.encode(packet([@body, @uc_zone, @uc_ring, @uc_rule, @handler]))
    r_12 = PacketEncoder.encode(packet([@body, @uc_zone, @uc_ring, @uc_rule, @uc_handler]))
    r_13 = PacketEncoder.encode(packet([@body, @uc_zone_default, @uc_ring, @rule, @handler]))
    r_14 = PacketEncoder.encode(packet([@body, @uc_zone_default, @uc_ring, @rule, @uc_handler]))
    r_15 = PacketEncoder.encode(packet([@body, @uc_zone_default, @ring, @uc_rule, @handler]))
    r_16 = PacketEncoder.encode(packet([@body, @uc_zone_default, @ring, @uc_rule, @uc_handler]))
    r_17 = PacketEncoder.encode(packet([@body, @uc_zone_default, @uc_ring, @uc_rule, @handler]))
    r_18 = PacketEncoder.encode(packet([@body, @uc_zone_default, @uc_ring, @uc_rule, @uc_handler]))

    assert r == "#(#{zone}:test){#{ring}}[#{handler}]::hello world"
    assert r_2 == "#(#{zone}:$){#{ring}}[#{handler}]::hello world"
    assert r_3 == "#(FooBar:test){#{ring}}<#{rule}>[#{handler}]::hello world"
    assert r_4 == "#(FooBar:$){#{ring}}<#{rule}>[#{handler}]::hello world"
    assert r_5 == "#(#{zone}:test){BazQux}[#{handler}]::hello world"
    assert r_6 == "#(#{zone}:$){BazQux}[#{handler}]::hello world"
    assert r_7 == "#(FooBar:test){BazQux}<#{rule}>[#{handler}]::hello world"
    assert r_8 == "#(FooBar:test){BazQux}<#{rule}>[custom_func]::hello world"
    assert r_9 == "#(FooBar:test){#{ring}}<QuuxQuuz>[#{handler}]::hello world"
    assert r_10 == "#(FooBar:test){#{ring}}<QuuxQuuz>[custom_func]::hello world"
    assert r_11 == "#(FooBar:test){BazQux}<QuuxQuuz>[#{handler}]::hello world"
    assert r_12 == "#(FooBar:test){BazQux}<QuuxQuuz>[custom_func]::hello world"
    assert r_13 == "#(FooBar:$){BazQux}<#{rule}>[#{handler}]::hello world"
    assert r_14 == "#(FooBar:$){BazQux}<#{rule}>[custom_func]::hello world"
    assert r_15 == "#(FooBar:$){#{ring}}<QuuxQuuz>[#{handler}]::hello world"
    assert r_16 == "#(FooBar:$){#{ring}}<QuuxQuuz>[custom_func]::hello world"
    assert r_17 == "#(FooBar:$){BazQux}<QuuxQuuz>[#{handler}]::hello world"
    assert r_18 == "#(FooBar:$){BazQux}<QuuxQuuz>[custom_func]::hello world"
  end
end

defmodule Moongate.Tests.Packets.Encoder do
  use ExUnit.Case, async: true
  alias Moongate.Packets.Encoder

  @body_fixtures %{
    without_body: %Moongate.Packet{body: nil},
    with_body: %Moongate.Packet{body: "Foo Bar"},
  }
  @deed_fixture %Moongate.Packet{deed: "TestDeed"}
  @domain_fixtures %{
    without_target: %Moongate.Packet{domain: :call},
    with_target: %Moongate.Packet{domain: {:call, :ring}}
  }
  @ring_fixtures %{
    none: %Moongate.Packet{ring: nil},
    without_id: %Moongate.Packet{ring: "TestRing"},
    with_id: %Moongate.Packet{ring: {"TestRing", 1}}
  }
  @zone_fixtures %{
    none: %Moongate.Packet{zone: nil},
    without_id: %Moongate.Packet{zone: "TestZone"},
    with_id: %Moongate.Packet{zone: {"TestZone", "$"}}
  }

  @full_packet_fixture %Moongate.Packet{
    body: "This is working.",
    deed: "TestDeed",
    domain: {:call, :ring},
    ring: {"TestRing", 1},
    zone: {"TestZone", "$"}
  }
  @full_packet_fixture_result "#[01:ring](TestZone:$){TestRing:1}<TestDeed>::This is working."

  test "&encode/1 for packet body" do
    assert Encoder.encode(@body_fixtures.without_body) == "#"
    assert Encoder.encode(@body_fixtures.with_body) == "#::Foo Bar"
  end

  test "&encode/1 for packet deed" do
    assert Encoder.encode(@deed_fixture) == "#<TestDeed>"
  end

  test "&encode/1 for packet domain" do
    assert Encoder.encode(@domain_fixtures.without_target) == "#[01]"
    assert Encoder.encode(@domain_fixtures.with_target) == "#[01:ring]"
  end

  test "&encode/1 for packet ring" do
    assert Encoder.encode(@ring_fixtures.none) == "#"
    assert Encoder.encode(@ring_fixtures.without_id) == "\#{TestRing}"
    assert Encoder.encode(@ring_fixtures.with_id) == "\#{TestRing:1}"
  end

  test "&encode/1 for packet zone" do
    assert Encoder.encode(@zone_fixtures.none) == "#"
    assert Encoder.encode(@zone_fixtures.without_id) == "#(TestZone)"
    assert Encoder.encode(@zone_fixtures.with_id) == "#(TestZone:$)"
  end

  test "&encode/1 for full packet" do
    assert Encoder.encode(@full_packet_fixture) == @full_packet_fixture_result
  end
end
defmodule Moongate.Tests.Packets.Decoder do
  use ExUnit.Case, async: true
  alias Moongate.PacketsDecoder

  @body_fixture "#::Foo Bar"
  @deed_fixture "#<TestDeed>"
  @domain_fixture "#[01]"
  @domain_fixture_full "#[0a:ring]"
  @ring_fixture "\#{TestRing}"
  @zone_fixture "#(TestZone)"
  @zone_fixture_full "#(TestZone:$)"

  @full_packet_fixture "#[01:ring](TestZone:$){TestRing}<TestDeed>::This is working."
  @full_packet_fixture_result %Moongate.Packet{
    body: "This is working.",
    deed: "TestDeed",
    domain: {:call, :ring},
    ring: "TestRing",
    zone: {"TestZone", "$"}
  }

  test "&decode/1 for packet body" do
    assert Decoder.decode(@body_fixture).body == "Foo Bar"
  end

  test "&decode/1 for packet deed" do
    assert Decoder.decode(@deed_fixture).deed == "TestDeed"
  end

  test "&decode/1 for packet domain" do
    assert Decoder.decode(@domain_fixture).domain == :call
    assert Decoder.decode(@domain_fixture_full).domain == {:set, :ring}
  end

  test "&decode/1 for packet ring" do
    assert Decoder.decode(@ring_fixture).ring == "TestRing"
  end

  test "&decode/1 for packet zone" do
    assert Decoder.decode(@zone_fixture).zone == "TestZone"
    assert Decoder.decode(@zone_fixture_full).zone == {"TestZone", "$"}
  end

  test "&decode/1 for full packet" do
    result = Decoder.decode(@full_packet_fixture)

    assert result.body == @full_packet_fixture_result.body
    assert result.deed == @full_packet_fixture_result.deed
    assert result.domain == @full_packet_fixture_result.domain
    assert result.ring == @full_packet_fixture_result.ring
    assert result.zone == @full_packet_fixture_result.zone
  end
end
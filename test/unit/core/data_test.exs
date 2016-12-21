defmodule Moongate.Tests.Core.Data do
  use ExUnit.Case, async: true

  test "%Moongate.Event{}" do
    fixture = %Moongate.Event{}
    keys = [
      :__pending_mutations,
      :body,
      :deed,
      :domain,
      :origin,
      :ring,
      :targets,
      :zone,
    ]

    assert Enum.all?(keys, &(Map.has_key?(fixture, &1)))
  end

  test "%Moongate.Fiber{}" do
    fixture = %Moongate.Fiber{}
    keys = [
      :command,
      :handler,
      :name,
      :params,
      :parent
    ]

    assert Enum.all?(keys, &(Map.has_key?(fixture, &1)))
  end

  test "%Moongate.Origin{}" do
    fixture = %Moongate.Origin{}
    keys = [
      :events,
      :id,
      :ip,
      :port,
      :protocol
    ]

    assert Enum.all?(keys, &(Map.has_key?(fixture, &1)))
  end

  test "%Moongate.Packet{}" do
    fixture = %Moongate.Packet{}
    keys = [
      :body,
      :deed,
      :domain,
      :ring,
      :zone
    ]

    assert Enum.all?(keys, &(Map.has_key?(fixture, &1)))
  end

  test "%Moongate.Ring{}" do
    fixture = %Moongate.Ring{}
    keys = [
      :__pending_mutations,
      :attributes,
      :deeds,
      :index,
      :members,
      :name,
      :ring,
      :zone,
      :zone_id,
      :subscribers
    ]

    assert Enum.all?(keys, &(Map.has_key?(fixture, &1)))
  end

  test "%Moongate.Web{}" do
    fixture = %Moongate.Web{}
    keys = [:path, :port]

    assert Enum.all?(keys, &(Map.has_key?(fixture, &1)))
  end

  test "%Moongate.Zone{}" do
    fixture = %Moongate.Zone{}
    keys = [
      :__pending_mutations,
      :id,
      :members,
      :rings,
      :name,
      :zone
    ]

    assert Enum.all?(keys, &(Map.has_key?(fixture, &1)))
  end
end
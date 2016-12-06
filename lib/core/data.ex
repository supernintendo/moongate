defmodule Moongate do
  defmodule Event do
    defstruct(
      __pending_mutations: [],
      body: nil,
      deed: nil,
      domain: nil,
      origin: nil,
      ring: nil,
      targets: [],
      zone: nil
    )
    defimpl Collectable do
      defdelegate into(original), to: Moongate.State, as: :into
    end
  end

  defmodule Fiber do
    defstruct(
      command: nil,
      name: nil,
      process: nil
    )
  end

  defmodule Origin do
    defstruct(
      events: nil,
      id: nil,
      ip: nil,
      port: nil,
      protocol: nil
    )
	end

  defmodule Packet do
    defstruct(
      body: nil,
      deed: nil,
      domain: nil,
      ring: nil,
      zone: nil
    )
  end

  defmodule Ring do
    defstruct(
      __pending_mutations: [],
      attributes: %{},
      deeds: %{},
      index: 0,
      members: [],
      name: nil,
      ring: nil,
      zone: nil,
      zone_id: nil,
      subscribers: []
    )
    defimpl Collectable do
      defdelegate into(original), to: Moongate.State, as: :into
    end
  end

  defmodule Socket do
    defstruct port: nil
  end

  defmodule Web do
    defstruct path: "client/", port: nil
  end

  defmodule Zone do
    defstruct(
      __pending_mutations: [],
      id: nil,
      members: %{},
      rings: [],
      name: "Untitled",
      zone: nil
    )
    defimpl Collectable do
      defdelegate into(original), to: Moongate.State, as: :into
    end
  end
end

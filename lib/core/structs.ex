defmodule Moongate do
  defmodule Fiber do
    defstruct command: nil, name: nil, process: nil
  end

  defmodule HTTP do
    defstruct path: "client/", port: nil
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
      __pending_mutations: [],
      cast: nil,
      error: nil,
      from: nil,
      origin: nil,
      params: nil,
      to: nil,
      use_deed: nil
    )
  end

  defmodule Registry do
    defstruct registry: nil
  end

  defmodule Ring do
    defstruct(
      __pending_mutations: [],
      attributes: %{},
      index: 0,
      members: [],
      name: nil,
      spec: nil,
      zone: nil,
      subscribers: []
    )
    defimpl Collectable do
      defdelegate into(original), to: Moongate.State, as: :into
    end
  end

  defmodule RingTransform do
    defstruct(
      by: 0,
      mode: "linear",
      time_started: nil
    )
  end

  defmodule Session do
    defstruct id: nil, origin: nil, zones: [], target_zone: nil
    defimpl Collectable do
      defdelegate into(original), to: Moongate.State, as: :into
    end
  end

  defmodule Socket do
    defstruct port: nil
  end

  defmodule Zone do
    defstruct(
      id: nil,
      members: [],
      rings: [],
      zone: nil
    )
    defimpl Collectable do
      defdelegate into(original), to: Moongate.State, as: :into
    end
  end

  defmodule ZoneEvent do
    defstruct(
      __pending_mutations: [],
      from: nil,
      origin: nil,
      params: nil
    )
    defimpl Collectable do
      defdelegate into(original), to: Moongate.State, as: :into
    end
  end
end
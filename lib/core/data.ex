defmodule Moongate do
  @moduledoc """
  The base namespace for Moongate. This module
  is only used as a prefix for other modules -
  it doesn't export or implement any functions.
  """

  defmodule Event do
    @moduledoc """
    Provides a data container for events passed to
    functions within world modules - this is the
    fundamental data structure that Moongate's
    DSL relies upon.
    """

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
    @moduledoc """
    Represents the state of a Moongate.Fiber.GenServer.
    """

    defstruct(
      command: nil,
      handler: nil,
      name: nil,
      params: nil,
      parent: nil
    )
  end

  defmodule Origin do
    @moduledoc """
    Represents a client.
    """

    defstruct(
      events: nil,
      id: nil,
      ip: nil,
      port: nil,
      protocol: nil
    )
	end

  defmodule Packet do
    @moduledoc """
    Represents a packet before it has been encoded.
    """

    defstruct(
      body: nil,
      deed: nil,
      domain: nil,
      ring: nil,
      zone: nil
    )
  end

  defmodule Ring do
    @moduledoc """
    Represents the state of a Moongate.Ring.GenServer.
    """

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

  defmodule Web do
    @moduledoc """
    Represents the state of a Moongate.Web.GenServer.
    """

    defstruct(
      path: "client/",
      port: nil
    )
  end

  defmodule Zone do
    @moduledoc """
    Represents the state of a Moongate.Zone.GenServer.
    """

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

defmodule Moongate.Zone.Node do
  import Moongate.Zone.Mutations
  use GenServer
  use Moongate.OS
  use Moongate.Mutations, genserver: true

  @doc """
    Start the zone process.
  """
  def start_link(params) do
    %Moongate.Zone{
      id: params[:id],
      zone: params[:zone]
    }
    |> establish
  end

  @doc """
    This is called after start_link has resolved.
  """
  def handle_cast({:init}, state) do
    log(:up, {:zone, "Zone (#{state.id})"})
    {:noreply, state |> init_rings}
  end

  @doc """
    Receive a message from an event listener and call
    the callback defined on the zone module.
  """
  def handle_cast({:tunnel, event}, state) do
    apply(state.zone, :takes, [{event.cast, event.params}, %{ event | from: state.id }])
    |> mutations(state)
    |> no_reply
  end

  @doc """
    Mutate the zone state to account for a dropped
    member.
  """
  def handle_cast({:depart, event}, state) do
    notify_depart(state, event.origin)

    apply(state.zone, :departure, [event])
    |> mutations(state)
    |> no_reply
  end

  @doc """
    Mutate the zone state to account for a new
    member based on the result of calling `arrival`
    on the zone module.
  """
  def handle_call({:arrive, origin}, _from, state) do
    notify_arrive(state, origin)

    apply(state.zone, :arrival, [
      %Moongate.ZoneEvent{
        from: Process.info(self)[:registered_name],
        origin: origin
    }])
    |> mutate({:join_this_zone, origin})
    |> mutations(state)
    |> reply(:ok)
  end

  @doc """
    Initialize all rings.
  """
  def init_rings(state) do
    rings = state.zone
    |> apply(:__moongate__zone_rings, [])
    |> Enum.map(&(init_ring(&1, state)))

    %{state | rings: rings}
  end

  @doc """
    Initialize one ring.
  """
  def init_ring(ring, state) do
    name = Moongate.Ring.Service.ring_process_name(state.id, ring)
    register(:ring, name, {name, state.id, ring})
    name
  end

  defp notify_arrive(state, origin) do
    socket_message(origin, {:join, :zone, state.id,
      "#{Moongate.Ring.Service.to_string_list(state.rings)}"
    })
    state
  end

  def notify_depart(state, origin) do
    socket_message(origin, {:leave, :zone, state.id, ""})
    state
  end
end

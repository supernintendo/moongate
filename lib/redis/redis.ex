defmodule Moongate.Redis do
  alias Moongate.{
    Core,
    CoreEvent,
    CoreTable
  }
  use GenServer

  @base_name CoreTable.base_name()
  @commands %CoreTable.Commands{
    delete: "DEL",
    get: "GET",
    get_map: "HGETALL",
    has_key?: "HEXISTS",
    list_delete: "LREM",
    list_push: "LPUSH",
    increment: "INCR",
    map_delete: "HDEL",
    map_get: "HGET",
    map_increment: "HINCRBY",
    map_keys: "HKEYS",
    map_merge: "HMSET",
    map_put: "HSET",
    match_keys: "KEYS",
    put: "SET",
    take: "HMGET",
    type: "TYPE"
  }

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def handle_call({:clear_namespace, namespace}, _from, state) do
    state = %{redis_conn: conn} = refresh_conn(state)
    clear_namespace(namespace, conn)

    {:reply, :ok, state}
  end

  def handle_call(params, _from, state) do
    state = %{redis_conn: conn} = refresh_conn(state)
    result = handle_params(params, conn)

    {:reply, result, state}
  end

  def handle_info(params, state) do
    state = %{redis_conn: conn} = refresh_conn(state)
    handle_params(params, conn)

    {:noreply, state}
  end

  def new_channel() do
    {:ok, pubsub} = Redix.PubSub.start_link()
    pubsub
  end

  defp handle_params({:command, message}, conn) do
    case redis_call(message) do
      nil ->
        nil
      call_args ->
        Redix.command(conn, call_args)
    end
  end

  defp handle_params({:pipeline, commands}, conn) do
    case redis_pipeline(commands) do
      [] ->
        []
      redis_commands ->
        Redix.pipeline(conn, redis_commands)
    end
  end

  defp handle_params({:publish, channel_name, args}, conn) do
    Redix.command!(conn, ["PUBLISH", channel_name, Enum.join(args, "|")])
  end

  defp clear_namespace(namespace, conn) do
    case Redix.command(conn, ["KEYS", "#{namespace}*"]) do
      {:ok, keys} when is_list(keys) and length(keys) > 0 ->
        Redix.pipeline(conn, Enum.map(keys, &(["DEL"] ++ [&1])))
      _ ->
        []
    end
  end

  defp redis_call({command_name, params}) do
    case Map.get(@commands, command_name) do
      nil ->
        nil
      command when command_name == :map_merge ->
        prepared_params =
          params
          |> List.last()
          |> map_fields()

        [command] ++ [List.first(params)] ++ prepared_params
      command ->
        [command] ++ params
    end
  end
  defp redis_call(_), do: nil

  defp redis_pipeline(commands) do
    commands
    |> Enum.map(&(redis_call(&1)))
    |> Enum.filter(&(&1))
  end

  defp refresh_conn(state) do
    conn = Map.get(state, :redis_conn)

    case conn && Process.alive?(conn) do
      true ->
        state
      _ ->
        {:ok, conn} = Redix.start_link()

        Map.put(state, :redis_conn, conn)
    end
  end

  defp map_fields(map) do
    map
    |> Map.to_list()
    |> Enum.flat_map(&Tuple.to_list/1)
    |> Enum.map(&cast/1)
  end

  defp cast(value) when is_atom(value), do: "#{value}"
  defp cast(value), do: value
end

defmodule Moongate.CoreTable do
  defmodule Commands do
    defstruct(
      delete: nil,
      get: nil,
      get_map: nil,
      has_key?: nil,
      list_delete: nil,
      list_push: nil,
      increment: nil,
      map_delete: nil,
      map_get: nil,
      map_increment: nil,
      map_keys: nil,
      map_merge: nil,
      map_put: nil,
      match_keys: nil,
      put: nil,
      take: nil,
      type: nil
    )
  end
  alias Moongate.{
    Core,
    CoreBootstrap,
    CoreNetwork
  }
  use Supervisor

  @base_name "mg_#{CoreBootstrap.game_name()}_#{Core.env()}"
  @table Application.get_env(:moongate, :table)
  @pool_options [
    name: {:local, :table_pool},
    worker_module: @table,
    size: 48,
    max_overflow: 16
  ]

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :table])
  end

  def init(_) do
    children = [:poolboy.child_spec(:table_pool, @pool_options, [])]
    supervise(children, strategy: :one_for_one)
  end

  def base_name, do: @base_name

  def async_command({command_name, params} = message) when is_list(params) do
    :poolboy.transaction(:table_pool, fn(pid) ->
      CoreNetwork.cast({:command, message}, pid)
    end)
  end

  def async_pipeline(commands) when is_list(commands) do
    :poolboy.transaction(:table_pool, fn(pid) ->
      CoreNetwork.cast({:pipeline, commands}, pid)
    end)
  end

  def async_publish(channel_name, args) do
    :poolboy.transaction(:table_pool, fn(pid) ->
      CoreNetwork.cast({:publish, channel_name, args}, pid)
    end)
  end

  def clear_namespace(namespace) do
    :poolboy.transaction(:table_pool, fn(pid) ->
      CoreNetwork.call({:clear_namespace, namespace}, pid)
    end)
  end

  def command({command_name, params} = message) when is_list(params) do
    :poolboy.transaction(:table_pool, fn(pid) ->
      CoreNetwork.call({:command, message}, pid)
    end)
  end

  def command!(message) do
    case command(message) do
      {:ok, result} -> result
      _ -> nil
    end
  end

  def new_channel() do
    @table.new_channel()
  end

  def pipeline(commands) when is_list(commands) do
    :poolboy.transaction(:table_pool, fn(pid) ->
      CoreNetwork.call({:pipeline, commands}, pid)
    end)
  end

  def pipeline!(commands) do
    case pipeline(commands) do
      {:ok, results} -> results
      _ -> []
    end
  end

  def publish(channel_name, args) do
    :poolboy.transaction(:table_pool, fn(pid) ->
      CoreNetwork.call({:publish, channel_name, args}, pid)
    end)
  end

  def delete(key), do: async_command({:delete, [key]})

  def get(key) do
    case command({:get, [key]}) do
      {:ok, value} -> value
      _ -> nil
    end
  end

  def has_key?(map_key, key) do
    case command({:has_key?, [map_key, key]}) do
      {:ok, result} -> result
      _ -> false
    end
  end

  def increment(key) do
    case command({:increment, [key]}) do
      {:ok, result} -> result
      _ -> nil
    end
  end

  def index(namespace) do
    match_keys("#{namespace}*")
  end

  def list_delete(list_key, value) do
    async_command({:list_delete, [list_key, value]})
  end

  def list_push(list_key, value) do
    async_command({:list_push, [list_key, value]})
  end

  def map_delete(map_key, key) do
    async_command({:map_delete, [map_key, key]})
  end

  def map_get(map_key, key) do
    case command({:map_get, [map_key, key]}) do
      {:ok, value} -> value
      _ -> nil
    end
  end

  def map_increment(map_key, key) do
    case command({:map_increment, [map_key, key]}) do
      {:ok, result} -> result
      _ -> nil
    end
  end

  def map_keys(map_key) do
    case command({:map_keys, [map_key]}) do
      {:ok, keys} -> keys
      _ -> nil
    end
  end

  def map_merge(map_key, map) when is_map(map) do
    async_command({:map_merge, [map_key, map]})
  end

  def map_put(map_key, key, value) do
    async_command({:map_put, [map_key, key, value]})
  end

  def match_keys(pattern) do
    case command({:match_keys, [pattern]}) do
      {:ok, results} -> results
      _ -> nil
    end
  end

  def put(key, value), do: async_command({:put, [key, value]})

  def take(map_key, key) do
    case command({:take, [map_key, key]}) do
      {:ok, result} -> result
      _ -> nil
    end
  end

  def type(keys) when is_list(keys) do
    case command({:type, keys}) do
      {:ok, value} -> value
      _ -> nil
    end
  end
  def type(key), do: type([key])
end

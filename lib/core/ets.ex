defmodule Moongate.CoreETS do
  @moduledoc """
  A basic wrapper for ETS.
  """
  use GenServer

  @default_opts [
    :named_table,
    :public,
    {:read_concurrency, true},
    {:write_concurrency, true},
  ]

  def start_link do
    GenServer.start_link(__MODULE__, %{
      cache: new_ets_table(:cache),
      counters: new_ets_table(:counters),
      packet: new_ets_table(:packet),
      registry: new_ets_table(:registry),
      ring: new_ets_table(:ring),
      session: new_ets_table(:session),
      zone: new_ets_table(:zone)
    }, [name: :ets])
  end

  def count(key) do
    case lookup({:counters, key}) do
      [{_key, value}] ->
        value
      _ ->
        0
    end
  end

  @doc """
  Deletes a value within an ETS table by key.
  """
  def delete({table_key, key}) do
    :ets.delete(table_key, key)
  end

  @doc """
  Retrieves a value within an ETS table by key.
  """
  def lookup({table_key, key}) do
    :ets.lookup(table_key, key)
  end

  def increment(key) do
    case lookup({:counters, key}) do
      [{key, value}] ->
        :ets.insert(:counters, {key, value + 1})
        value
      _ ->
        :ets.insert(:counters, {key, 1})
        0
    end
  end

  @doc """
  Returns all key value pairs within an ETS table as
  a map.
  """
  def index(table_key) do
    :ets.tab2list(table_key)
    |> Enum.into(%{})
  end

  @doc """
  Inserts a key value pair into an ETS table.
  """
  def insert({table_key, key, data}) do
    :ets.insert(table_key, {key, data})
  end

  @doc """
  Matches key value pairs within an ETS table
  against the specified pattern.
  """
  def match_object({table_key, pattern}) do
    :ets.match_object(table_key, pattern)
  end

  def mutate_state({table_key, key, function}) do
    case lookup({table_key, key}) do
      [key, value] -> {:ok, insert({table_key, key, apply(function, [value])})}
      _ -> {:error, "#{key} not found in #{table_key}."}
    end
  end

  # Initializes an ETS table.
  defp new_ets_table(key), do: new_ets_table(key, @default_opts)
  defp new_ets_table(key, opts) do
    :ets.new(key, opts)
  end
end

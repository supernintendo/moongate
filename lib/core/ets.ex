defmodule Moongate.ETS do
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
    %{
      cache: new_ets_table(:cache),
      registry: new_ets_table(:registry),
      ring: new_ets_table(:ring)
    }
    |> Moongate.Network.establish("ets", __MODULE__)
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

  # Initializes an ETS table.
  defp new_ets_table(key), do: new_ets_table(key, @default_opts)
  defp new_ets_table(key, opts) do
    :ets.new(key, opts)
  end
end

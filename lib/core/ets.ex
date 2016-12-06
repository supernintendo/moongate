defmodule Moongate.ETS do
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
    |> Moongate.Network.establish(__MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:shutdown}, _from, _state) do
  end

  def delete({table_key, key}) do
    :ets.delete(table_key, key)
  end

  def lookup({table_key, key}) do
    :ets.lookup(table_key, key)
  end

  def index(table_key) do
    :ets.tab2list(table_key)
    |> Enum.into(%{})
  end

  def insert({table_key, key, data}) do
    :ets.insert(table_key, {key, data})
  end

  def match_object({table_key, match}) do
    :ets.match_object(table_key, match)
  end

  defp new_ets_table(key), do: new_ets_table(key, @default_opts)
  defp new_ets_table(key, opts) do
    :ets.new(key, opts)
  end
end

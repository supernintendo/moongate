defmodule Moongate.Support do
  use GenServer

  @trapped_pids_file "priv/temp/#{Moongate.Core.world_name}.pids"

  def start_link do
    clear_trapped_pids

    %{}
    |> Moongate.Network.establish("support", __MODULE__)
  end

  def handle_cast({:file_changed, filename}, state) do
    filename
    |> String.split("\n")
    |> List.first
    |> handle_path

    {:noreply, state}
  end

  def trap_os_pid(pid) do
    {:ok, cache} = EON.from_file(@trapped_pids_file)

    EON.to_file(%{pids: cache.pids ++ [pid]}, @trapped_pids_file)
  end

  defp clear_trapped_pids do
    {:ok, @trapped_pids_file} = EON.to_file(%{pids: []}, @trapped_pids_file)
  end

  defp handle_path(path) do
    cond do
      Regex.match?(~r/\.ex/, path) ->
        IO.puts "foo"
        IEx.Helpers.recompile
      true -> nil
    end
  end
end
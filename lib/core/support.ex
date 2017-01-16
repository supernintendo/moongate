defmodule Moongate.CoreSupport do
  use GenServer

  @pids_file "priv/temp/#{Moongate.Core.world_name}.pids"

  def start_link do
    clear_trapped_pids()

    %{}
    |> Moongate.CoreNetwork.establish("support", __MODULE__)
  end

  @doc """
  Attempts to exit the server gracefully. This
  effectively calls :init.stop, causing any processes
  which are trapping exits to receive exit signals.
  """
  def handle_cast(:quit, state) do
    Moongate.Core.log({:status, "Moongate will terminate shortly..."})
    :init.stop

    {:noreply, state}
  end

  @doc """
  Indicates that a file on the local filesystem has
  been modified.
  """
  def handle_cast({:file_changed, filename}, state) do
    filename
    |> String.split("\n")
    |> List.first
    |> handle_path

    {:noreply, state}
  end

  @doc """
  Traps an OS pid so that it may be killed when Moongate
  terminates. This causes the pid to be written to the
  pids file for the current world (located in priv/temp).
  Trapped OS pids will only be terminated if Moongate
  has been started using the `moongate` shell script.
  """
  def trap_os_pid(os_pid) do
    {:ok, cache} = EON.from_file(@pids_file)

    EON.to_file(%{pids: cache.pids ++ [os_pid]}, @pids_file)
  end

  # Clear the trapped pids file for the current world.
  defp clear_trapped_pids do
    {:ok, @pids_file} = EON.to_file(%{pids: []}, @pids_file)
  end

  # Handle a file change. For .ex files, this will cause
  # the module to be recompiled.
  defp handle_path(path) do
    cond do
      Regex.match?(~r/\.ex/, path) ->
        IEx.Helpers.recompile
      true -> nil
    end
  end
end
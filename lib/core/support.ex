defmodule Moongate.CoreSupport do
  alias Moongate.{
    Core,
    CoreTable
  }
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, [name: :support])
  end

  def handle_cast({:dispatch, event}, state) do
    Core.dispatch(event)

    {:noreply, state}
  end

  @doc """
  Attempts to exit the server gracefully. This
  effectively calls :init.stop, causing any processes
  which are trapping exits to receive exit signals.
  """
  def handle_info(:quit, state) do
    Core.log({:info, "Moongate will terminate shortly..."})
    :init.stop

    {:noreply, state}
  end

  @doc """
  Indicates that a file on the local filesystem has
  been modified.
  """
  def handle_info({:file_changed, filename}, state) do
    filename
    |> String.split("\n")
    |> List.first()
    |> handle_path()

    {:noreply, state}
  end

  def pid_info(pid) when is_pid(pid) do
    pid
  end
  def pid_info(_), do: nil

  @doc """
  Traps an OS pid so that it may be killed when Moongate
  terminates. This causes the pid to be written to the
  pids file for the current game (located in priv/temp).
  Trapped OS pids will only be terminated if Moongate
  has been started using the `moongate` shell script.
  """
  def trap_os_pid(name, os_pid) do
    CoreTable.map_put("#{CoreTable.base_name()}-pids", name, os_pid)

    :ok
  end

  def untrap_os_pid(name) do
    CoreTable.map_delete("#{CoreTable.base_name()}-pids", name)

    :ok
  end

  # Handle a file change. For .ex files, this will cause
  # the module to be recompiled.
  defp handle_path(path) do
    cond do
      Regex.match?(~r/\.ex/, path) ->
        IEx.Helpers.recompile
      true ->
        nil
    end
  end
end

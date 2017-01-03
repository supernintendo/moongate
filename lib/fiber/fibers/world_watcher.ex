defmodule Moongate.Fibers.WorldWatcher do
  @watch_command Application.get_env(:moongate, :file_watcher)

  def start(parent) do
    proc =
      {:spawn, "#{@watch_command} #{Moongate.Core.world_directory}"}
      |> Port.open([:binary])
    os_pid = Port.info(proc)[:os_pid]
    Moongate.CoreSupport.trap_os_pid(os_pid)

    state = %{
      parent => parent,
      proc => proc
    }
    wait(state)
  end

  def wait(state) do
    receive do
      {_port, {:data, filename}} ->
        filename
        |> parse_filename
        |> handle_file_changed
      _ -> nil
    end
    wait(state)
  end

  defp parse_filename(filename) do
    parsed_filename =
      filename
      |> String.split("\n")
      |> List.first

    {parsed_filename, Path.extname(parsed_filename)}
  end

  defp handle_file_changed({filename, extension}) do
    case extension do
      ".ex" -> recompile_module(filename)
      _ -> nil
    end
  end

  defp recompile_module(filename) do
    Code.eval_file(filename)
  end
end
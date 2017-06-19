defmodule Mix.Tasks.Moongate.Clean do
  alias Moongate.CoreFirmware
  require Logger
  use Mix.Task

  @shortdoc "Kills all processes started by the most recent Moongate instance"
  def run(_args) do
    clean(CoreFirmware.game_name())
  end

  defp clean(game) do
    case Eon.read(session_filename(game)) do
      {:ok, session_data} ->
        session_data
        |> Map.put(:game_name, game)
        |> kill_external_pids()
        |> delete_session_file()
      {:error, _} ->
        Logger.warn("Session file for #{game} is missing or invalid.")
    end
  end

  defp kill_external_pids(%{pids: pids} = session_data) do
    Enum.map(pids, fn pid ->
      System.cmd("kill", ["#{pid}"])
    end)
    session_data
  end
  defp kill_external_pids(session_data), do: session_data

  defp delete_session_file(%{game_name: game}) do
    game
    |> session_filename()
    |> File.rm()
  end
  defp delete_session_file(session_data), do: session_data

  defp session_filename(game), do: "priv/temp/#{game}.session.exs"
end

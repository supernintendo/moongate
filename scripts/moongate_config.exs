defmodule MoongateConfig do
  require Logger

  def call do
    path = Path.expand(System.get_env("MOONGATE_GAME_PATH"))

    case File.read("#{path}/moongate.json") do
      {:ok, _contents} -> :ok
      {:error, :enoent} -> use_relative_directory_or_fail(path)
      {:error, :eacces} -> error("Missing permission to load moongate.json")
      {:error, :enomem} -> error("Not enough memory")
      _ -> error("Unknown error")
    end
  end

  def use_relative_directory_or_fail(path) do
    system_games_path = Path.expand("./games/#{System.get_env("MOONGATE_GAME_PATH")}")

    case File.read("#{system_games_path}/moongate.json") do
      {:ok, _contents} ->
        :ok
      {:error, :enoent} ->
        system_games = get_system_games()
        alert("#{IO.ANSI.red()}", "No moongate.json found at #{path}")
        alert("#{IO.ANSI.red()}", "No moongate.json found at #{system_games_path}")
        if String.trim(system_games) != "" do
          IO.puts ~s(
  #{IO.ANSI.black()}Try one of the following:
  #{IO.ANSI.green()}
  #{system_games}
          )
        end
        System.halt(1)
    end
  end

  defp alert(prefix, string) do
    IO.puts "#{prefix}#{inspect __MODULE__}: #{string}#{IO.ANSI.reset()}"
    string
  end

  defp error(message) do
    IO.puts "#{inspect __MODULE__}: #{message}"
    System.halt(1)
  end

  defp get_system_games() do
    case File.ls("./games") do
      {:ok, contents} ->
        contents
        |> Enum.filter(&(File.dir?("./games/#{&1}")))
        |> Enum.filter(&(File.exists?("./games/#{&1}/moongate.json")))
        |> Enum.with_index()
        |> Enum.group_by(&(rem(elem(&1, 1) + 1, 4)), &(elem(&1, 0)))
        |> Enum.map(&(elem(&1, 1)))
        |> Enum.map(&(Enum.join(&1, ", ")))
        |> Enum.join("\n  ")
      _ -> nil
    end
  end
end

MoongateConfig.call()

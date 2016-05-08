defmodule Mix.Tasks.Moongate.Load do
  @shortdoc "Load a world."
  use Mix.Task

  def run(args = []) do
    IO.puts(
    IO.chardata_to_string(
      IO.ANSI.format_fragment(
        [:red, "Please provide a world name." <> IO.ANSI.reset], true)))
    IO.puts ""
    IO.puts world_list
  end

  def run(args) do
    defaults = %{
      db: "localhost/moongate",
      db_user: {"moongate", "moongate"}
    }
    world = hd(args)
    {:ok, config} = EON.from_file("priv/worlds/#{world}/moongate.peon")
    prepared = defaults |> Map.merge(config)
    {username, password} = prepared.db_user
    result = "#{world}\n#{username}:#{password}@#{prepared.db}"
    {:ok, file} = File.open("priv/temp/user", [:write])
    IO.binwrite(file, result)
    Mix.Tasks.Clean.run([])

    IO.puts(
      IO.chardata_to_string(
      ["Loaded world "] ++
      IO.ANSI.format_fragment(
        [:blue, "#{world}" <> IO.ANSI.reset <> "."], true)))
  end

  defp world_list do
    IO.chardata_to_string(["The worlds you can load are: "] ++
      IO.ANSI.format_fragment(
        [:cyan, "#{world_dirs}" <> IO.ANSI.reset], true))
  end

  defp world_dirs do
    {:ok, ls} = File.ls("priv/worlds")
    ls
    |> Enum.filter(&(File.dir?("priv/worlds/#{&1}")))
    |> Enum.join(" ")
  end
end

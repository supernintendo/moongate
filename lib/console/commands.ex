defmodule Moongate.ConsoleCommands do
  @commands %{
    "cli :h" => "View this text.",
    "moon :a" => "View version and system information.",
    "moon :q" => "Terminate the server gracefully.",
    "zone :l" => "View list of zones"
  }

  def init_message do
    [
      :reset,
      :inverse,
      "Moongate IEx additions",
      :color240,
      " loaded. Enter '",
      :color86,
      '`cli :h`',
      :color240,
      "' to see a list of commands.",
      :reset,
      "\n"
    ]
    |> Bunt.ANSI.format
    |> IO.puts
  end

  def cli(command) do
    case command do
      :h ->
        Moongate.Core.log({:info, @commands})
      _ -> nil
    end
  end

  def moon(command) do
    case command do
      :a -> Moongate.Core.log(:moongate_banner)
      :q ->  GenServer.cast(:support, :quit)
      _ -> nil
    end
  end

  def zone(command) do
    case command do
      :l -> Moongate.Core.zones
      _ -> nil
    end
  end
end
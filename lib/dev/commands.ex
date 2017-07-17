defmodule Moongate.DevCommands do
  alias Moongate.{
    Core,
    CoreNetwork,
    CoreUtility
  }

  @commands %{
    "Help" => "View this text",
    "About" => "View version and system information",
    "Quit" => "Terminate the server gracefully",
    "Zone, {:zone, :id}" => "Return information about a zone",
    "Zones" => "View list of zones"
  }

  def init do
    [
      :reset,
      :inverse,
      "Moongate IEx additions",
      :color240,
      " loaded. Enter '",
      :color86,
      '`mg Help`',
      :color240,
      "' to see a list of commands.",
      :reset,
      "\n"
    ]
    |> Bunt.ANSI.format
    |> IO.puts
  end

  def mg, do: mg(nil)
  def mg(input), do: mg(input, [])
  def mg(input, args) when is_list(args) do
    command =
      input
      |> CoreUtility.atom_to_string
      |> String.downcase

    case command do
      "about" -> Core.log({:banner, Moongate.DevArt.random})
      "help" -> Core.log({:info, commands()})
      "quit" ->  CoreNetwork.cast(:quit, Process.whereis(:support))
      "zone" -> zone_info(List.first(args))
      "zones" -> Moongate.Zone.index()
      _ -> unknown_command(command)
    end
  end
  def mg(input, arg), do: mg(input, [arg])

  defp commands do
    @commands
    |> Enum.map(fn {key, value} -> {"mg #{key}", value} end)
    |> Enum.into(%{})
  end

  defp unknown_command(command) when is_atom(command) do
    unknown_command(CoreUtility.atom_to_string(command))
  end
  defp unknown_command(_command) do
    Core.log({:warning, "I'm not sure what you mean."})
    :sorry
  end

  defp zone_info(_zone = nil), do: nil
  defp zone_info(zone) do
    pid = Core.pid(zone)

    case GenServer.call(pid, :info) do
      {:ok, zone_info} ->
        print_zone_info(zone_info)
        zone_info.pids
      _ ->
        nil
    end
  end

  defp print_zone_info(result) when is_map(result) do
    result.ring_counts
    |> CoreUtility.formatted_quantities
    |> Enum.join("")
    |> String.downcase
    |> print_zone_info(result)
  end

  defp print_zone_info("", %{zone: _zone} = result), do: print_zone_info("no rings", result)
  defp print_zone_info(rings_string, %{zone: zone} = result) when is_bitstring(rings_string) do
    members_string = CoreUtility.formatted_quantity("member", length(Map.keys(result.members)))
    zone_string = CoreUtility.atom_to_string(zone) |> String.downcase

    [
      :bright,
      :color39,
      "#{CoreUtility.atom_to_string(zone)}",
      :reset,
      "\nThis #{zone_string} has #{members_string}.",
      "\nThis #{zone_string} has #{rings_string}."
    ]
    |> Bunt.ANSI.format
    |> IO.puts
  end
  defp print_zone_info(_, _), do: nil
end

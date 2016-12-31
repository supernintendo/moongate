defmodule Moongate.Console do
  use GenServer

  @init_message [
    :reset,
    :inverse,
    "Moongate IEx additions",
    :color240,
    " loaded. Type '",
    :color86,
    'help',
    :color240,
    "' to see a list of commands.",
    :reset,
    "\n"
  ]

  def start_link do
    init_message
    %{
      context: :world
    }
    |> Moongate.Network.establish("console", __MODULE__)
  end

  def handle_cast(:refresh, state) do
    set_prompt(state)

    {:noreply, state}
  end

  defp init_message do
    IO.puts(Bunt.ANSI.format(@init_message))
  end

  def set_prompt(state) do
    if IEx.started? do
      IEx.configure(
        colors: [enabled: true],
        default_prompt: format_prompt(context(state.context))
      )
    end
  end

  defp context(:world) do
    {"World", :blue}
  end
  defp context(_), do: {"%prefix", :white}

  defp format_prompt({string, color}) do
    ["\e[G", :inverse, color, "#{string} :", :reset]
    |> Bunt.ANSI.format
    |> IO.chardata_to_string
  end
end
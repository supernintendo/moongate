defmodule Moongate.Dev do
  use GenServer

  def start_link(_config) do
    GenServer.start_link(__MODULE__, %{ context: :game }, [name: :dev])
  end

  def handle_cast(:refresh, state) do
    set_prompt(state)

    {:noreply, state}
  end

  def set_prompt(state) do
    if IEx.started? do
      IEx.configure(
        colors: [enabled: true],
        default_prompt: format_prompt(context(state.context))
      )
    end
  end

  defp context(:game) do
    {"#", :blue}
  end
  defp context(_), do: {"%prefix", :white}

  defp format_prompt({string, color}) do
    ["\e[G", :inverse, color, "#{string} :", :reset]
    |> Bunt.ANSI.format
    |> IO.chardata_to_string
  end
end

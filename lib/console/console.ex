defmodule Moongate.Console do
  use GenServer

  def start_link do
    %{
      context: :world
    }
    |> Moongate.CoreNetwork.establish("console", __MODULE__)
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

  defp context(:world) do
    {"#", :blue}
  end
  defp context(_), do: {"%prefix", :white}

  defp format_prompt({string, color}) do
    ["\e[G", :inverse, color, "#{string} :", :reset]
    |> Bunt.ANSI.format
    |> IO.chardata_to_string
  end
end
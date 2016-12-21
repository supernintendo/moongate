defmodule Moongate.Console do
  use GenServer

  @init_message [
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
    %{
      context: :world
    }
    |> Moongate.Network.establish("console", __MODULE__)
  end

  def init_message do
    IO.puts(Bunt.ANSI.format(@init_message))
  end

  def handle_call(:foo, _from, state) do
    set_prompt(:world)
    {:reply, nil, state}
  end

  def set_prompt(:world) do
    set_prompt("(World) :")
  end

  def set_prompt(string) do
    if IEx.started? do
      IEx.configure(default_prompt: string)
    end
  end
end

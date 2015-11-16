defmodule Moongate.RecursiveSwitch do
  defstruct arguments: [], callback: nil, response: nil, value: nil
end

defmodule Moongate.Recursive do
  use GenServer
  use Moongate.Macros.Processes

  def start_link({state, name}) do
    link(state, "recursive", name)
  end

  def handle_cast({:init}, state) do
    GenServer.cast(self(), {:tick})
    {:noreply, state}
  end

  def handle_cast({:tick}, %Moongate.RecursiveSwitch{} = state) do
    result = apply(state.callback, [state.arguments])
    GenServer.cast(self(), {:tick})

    if result != state.value do
      respond(state, result)
      {:noreply, %{state | value: result}}
    else
      {:noreply, state}
    end
  end

  def handle_cast({:publish, contents, :this}, state) do
    case state.arguments do
      {first, _, third, fourth} ->
        {:noreply, %{state | arguments: {first, contents, third, fourth}}}
      _ ->
        {:noreply, state}
    end
  end

  def handle_cast({:publish, contents, :that}, state) do
    case state.arguments do
      {first, second, _, fourth} ->
        {:noreply, %{state | arguments: {first, second, contents, fourth}}}
      _ ->
        {:noreply, state}
    end
  end

  defp respond(state, result) do
    case state.response do
      {pid, tag} -> tell_pid_async(pid, {tag, result})
      _ -> nil
    end
  end
end

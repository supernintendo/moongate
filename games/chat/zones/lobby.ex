defmodule Chat.Lobby do
  use Moongate.DSL, :zone

  rings []

  handle "start", ev do
    ev
  end

  handle "join", ev do
    ev
    |> notify_player(&broadcast_player_count/1)
    |> notify_others("A new client has joined.")
  end

  handle "leave", ev do
    ev
    |> target(&(&1))
    |> echo("A client has left.")
  end

  handle "save", %{params: %{save_state: _save_state}} = ev do
    ev
  end

  handle "post_message", %{arguments: {message}} = ev do
    ev
    |> notify_player("You said: #{message}")
    |> notify_others("Another client said: #{message}")
  end
  handle "post_message", ev do
    ev
  end

  defp notify_player(ev, message) do
    ev
    |> retarget(&(&1))
    |> assign(:player_count, &(length(&1.targets)))
    |> retarget(&(&1.id == ev.origin.id))
    |> echo(message)
  end

  defp notify_others(ev, message) do
    ev
    |> retarget(&(&1.id != ev.origin.id))
    |> echo(message)
  end

  defp broadcast_player_count(ev) do
    case ev.assigns[:player_count] - 1 do
      count when count > 1 -> "Welcome! There are #{count} other clients here."
      1 -> "Welcome! There is one other client here."
      _ -> "Welcome! There are no other clients here."
    end
  end
end

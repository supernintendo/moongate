defmodule Moongate.Macros.Processes do
  defmacro __using__(_) do
    quote do
      defp ask(message, name) do
        pid = pid_for_name(name)
        Moongate.Processes.ask_pid(message, pid)
      end
      defp ask(message, namespace, id) do
        pid = pid_for_name("namespace_#{id}")
        Moongate.Processes.ask_pid(message, pid)
      end

      defp ask_pid(message, pid), do: Moongate.Processes.ask_pid(message, pid)

      defp kill_pid(namespace, pid), do: Moongate.Processes.kill_pid(namespace, pid)

      defp link(params) do
        GenServer.start_link(__MODULE__, params)
      end

      defp link(params, name) do
        GenServer.start_link(__MODULE__, params, [name: String.to_atom(name)])
      end

      defp link(params, namespace, name) do
        if is_atom(namespace), do: namespace = Atom.to_string(namespace)
        if is_atom(name), do: name = Atom.to_string(name)
        if namespace != "", do: namespace = namespace <> "_"

        GenServer.start_link(__MODULE__, params, [name: String.to_atom(namespace <> name)])
      end

      # A shortcut for {:noreply, state} that is easier
      # to pipe into.
      defp no_reply(state) do
        {:noreply, state}
      end

      defp pid_for_name(name) do
        case Moongate.Processes.lookup(name) do
          [{^name, pid}] -> pid
          _ -> nil
        end
      end

      defp register(namespace), do: register(namespace, nil)
      defp register(namespace, params), do: register(namespace, UUID.uuid4(:hex), params)
      defp register(namespace, name, params) do
        Moongate.Processes.register(namespace, name, params)
      end

      # A shortcut for {:noreply, state} that is easier
      # to pipe into.
      defp reply(state, reply) do
        {:reply, reply, state}
      end

      defp tell(message, name) do
        pid = pid_for_name(name)
        Moongate.Processes.tell_pid(message, pid)
      end
      defp tell(message, namespace, id) do
        pid = pid_for_name("#{namespace}_#{id}")
        Moongate.Processes.tell_pid(message, pid)
      end

      defp tell_all(message, namespace) do
        case Moongate.Processes.lookup("tree_#{namespace}") do
          [{^namespace, supervisor}] ->
            supervisor
            |> Supervisor.which_children
            |> Enum.map(&tell_pid(message, elem(&1, 1)))
          [] -> nil
        end
      end

      defp tell_pid(message, pid), do: Moongate.Processes.tell_pid(message, pid)
    end
  end
end

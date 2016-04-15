defmodule Moongate.ProcessCapabilities do
  defstruct(
    can_be_cast_to: false,
    can_be_called: false,
    can_receive: false
  )
end

defmodule Moongate.Macros.Processes do
  defmacro __using__(_) do
    quote do
      defp capabilities_for(pid) do
        if pid != nil do
          {mod, _, _} = Process.info(pid)[:dictionary][:"$initial_call"]

          %Moongate.ProcessCapabilities{
            can_be_called: mod.__info__(:functions)[:handle_call] == 3,
            can_be_cast_to: mod.__info__(:functions)[:handle_cast] == 2,
            can_receive: mod.__info__(:functions)[:receive_loop] == 1
          }
        else
          %Moongate.ProcessCapabilities{}
        end
      end

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

      defp kill_by_id(namespace, id) do
        pid = pid_for_name(namespace, id)
        if pid, do: kill_by_pid(namespace, pid)
      end

      defp kill_by_pid(namespace, pid) do
        GenServer.call(:registry, {:kill_by_pid, namespace, pid})
      end

      defp pid_for_name(namespace, id) do
        Process.whereis(String.to_atom("#{namespace}_#{id}"))
      end

      defp spawn_new(namespace), do: spawn_new(namespace, nil)
      defp spawn_new(namespace, params) do
        GenServer.call(:registry, {:spawn, namespace, params})
      end

      defp tell!(message, name) do
        pid = Process.whereis(name)
        capabilities = capabilities_for(pid)

        if capabilities.can_be_called do
          result = GenServer.call(name, message)
        end
        if capabilities.can_receive, do: result = send(pid, message)

        result
      end

      defp tell!(message, namespace, id) do
        pid = pid_for_name(namespace, id)
        capabilities = capabilities_for(pid)

        if capabilities.can_be_called, do: result = GenServer.call(String.to_atom("#{namespace}_#{id}"), message)
        if capabilities.can_receive, do: result = send(pid, message)

        result
      end

      defp tell_all(message, namespace) do
        GenServer.cast(:registry, {:tell_all, namespace, message})
      end

      defp tell(message, name) do
        pid = Process.whereis(name)
        capabilities = capabilities_for(pid)
        if capabilities.can_be_cast_to, do: GenServer.cast(name, message)
        if capabilities.can_receive, do: send(pid, message)
      end

      defp tell(message, namespace, id) do
        pid = pid_for_name(namespace, id)
        capabilities = capabilities_for(pid)
        if capabilities.can_be_cast_to, do: GenServer.cast(pid, message)
        if capabilities.can_receive, do: send(pid, message)
      end

      defp tell_pid!(message, pid) do
        capabilities = capabilities_for(pid)

        if capabilities.can_be_called, do: result = GenServer.call(pid, message)
        if capabilities.can_receive, do: result = send(pid, message)

        result
      end

      defp tell_pid(message, pid) do
        capabilities = capabilities_for(pid)

        if capabilities.can_be_cast_to, do: GenServer.cast(pid, message)
        if capabilities.can_receive, do: send(pid, message)
      end

      # A shortcut for {:noreply, state} that is easier
      # to pipe into.
      defp no_reply(state) do
        {:noreply, state}
      end

      # A shortcut for {:noreply, state} that is easier
      # to pipe into.
      defp reply(state, reply) do
        {:reply, reply, state}
      end
    end
  end
end

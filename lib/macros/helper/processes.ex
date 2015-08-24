defmodule Moongate.ProcessCapabilites do
  defstruct can_be_cast_to: false, can_be_called: false, can_receive: false
end

defmodule Moongate.Macros.Processes do
  defmacro __using__(_) do
    quote do
      defp capabilities_for(pid) do
        if pid != nil do
          {mod, _, _} = Process.info(pid)[:dictionary][:"$initial_call"]

          %Moongate.ProcessCapabilites{
            can_be_called: mod.__info__(:functions)[:handle_call] == 3,
            can_be_cast_to: mod.__info__(:functions)[:handle_cast] == 2,
            can_receive: mod.__info__(:functions)[:receive_loop] == 1
          }
        else
          %Moongate.ProcessCapabilites{}
        end
      end

      defp link(params, name) do
        link(params, "", name)
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
        GenServer.call(:tree, {:kill_by_pid, namespace, pid})
      end

      defp pid_for_name(namespace, id) do
        Process.whereis(String.to_atom("#{namespace}_#{id}"))
      end

      defp spawn_new(namespace, params) do
        GenServer.call(:tree, {:spawn, namespace, params})
      end

      defp tell(name, message) do
        pid = Process.whereis(name)
        capabilites = capabilities_for(pid)

        if capabilites.can_be_called, do: result = GenServer.call(name, message)
        if capabilites.can_receive, do: result = send(pid, message)

        result
      end

      defp tell(namespace, id, message) do
        pid = pid_for_name(namespace, id)
        capabilites = capabilities_for(pid)

        if capabilites.can_be_called, do: result = GenServer.call(String.to_atom("#{namespace}_#{id}"), message)
        if capabilites.can_receive, do: result = send(pid, message)

        result
      end

      defp tell_all_async(namespace, message) do
        GenServer.cast(:tree, {:tell_async_all_children, namespace, message})
      end

      defp tell_async(name, message) do
        pid = Process.whereis(name)
        capabilites = capabilities_for(pid)

        if capabilites.can_be_cast_to, do: GenServer.cast(name, message)
        if capabilites.can_receive, do: send(pid, message)
      end

      defp tell_async(namespace, id, message) do
        pid = pid_for_name(namespace, id)
        capabilites = capabilities_for(pid)

        if capabilites.can_be_cast_to, do: GenServer.cast(pid, message)
        if capabilites.can_receive, do: send(pid, message)
      end

      defp tell_pid(pid, message) do
        capabilites = capabilities_for(pid)

        if capabilites.can_be_called, do: result = GenServer.call(pid, message)
        if capabilites.can_receive, do: result = send(pid, message)

        result
      end

      defp tell_pid_async(pid, message) do
        capabilites = capabilities_for(pid)

        if capabilites.can_be_cast_to, do: GenServer.cast(pid, message)
        if capabilites.can_receive, do: send(pid, message)
      end
    end
  end
end

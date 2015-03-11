defmodule Macros.Translator do
  defmacro __using__(_) do
    quote do
      use GenServer
      defp pid_for_name(namespace, id) do
        Process.whereis(String.to_atom("#{namespace}_#{id}"))
      end

      defp get(namespace, params) do
        GenServer.cast(:tree, {:get, namespace, params})
      end

      defp kill_by_id(namespace, id) do
        pid = pid_for_name(namespace, id)
        if pid, do: kill_by_pid(namespace, pid)
      end

      defp kill_by_pid(namespace, pid) do
        GenServer.call(:tree, {:kill_by_pid, namespace, pid})
      end

      defp tell_all_async(namespace, message) do
        GenServer.cast(:tree, {:tell_async_all_children, namespace, message})
      end

      defp tell_sync(name, message) do
        GenServer.call(name, message)
      end

      defp tell_sync(namespace, id, message) do
        pid = pid_for_name(namespace, id)
        if pid, do: GenServer.call(String.to_atom("#{namespace}_#{id}"), message)
      end

      defp tell_async(name, message) do
        GenServer.cast(name, message)
      end

      defp tell_async(namespace, id, message) do
        pid = pid_for_name(namespace, id)
        if pid, do: GenServer.cast(String.to_atom("#{namespace}_#{id}"), message)
      end

      defp tell_pid_sync(pid, message) do
        GenServer.call(pid, message)
      end

      defp tell_pid_async(pid, message) do
        GenServer.cast(pid, message)
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

      defp spawn_new(namespace, params) do
        GenServer.call(:tree, {:spawn, namespace, params})
      end
    end
  end
end

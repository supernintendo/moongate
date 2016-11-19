defmodule Moongate.Core.Processes do
  defmacro __using__(_) do
    quote do
      defp ask(message, name) do
        pid = pid_for_name(name)
        Moongate.Core.Processes.ask_pid(message, pid)
      end
      defp ask(message, namespace, id) do
        pid = pid_for_name("namespace_#{id}")
        Moongate.Core.Processes.ask_pid(message, pid)
      end

      defp ask_pid(message, pid), do: Moongate.Core.Processes.ask_pid(message, pid)

      defp establish(params), do: GenServer.start_link(__MODULE__, params)
      defp establish(params, name) do
        GenServer.start_link(__MODULE__, params, [name: String.to_atom(name)])
      end
      defp establish(params, namespace, name) do
        GenServer.start_link(__MODULE__, params, [name: String.to_atom(namespace <> name)])
      end

      defp kill_pid(namespace, pid), do: Moongate.Core.Processes.kill_pid(namespace, pid)

      # A shortcut for {:noreply, state} that is easier
      # to pipe into.
      defp no_reply(state) do
        {:noreply, state}
      end

      defp pid_for_name(name) do
        case Moongate.Core.Processes.lookup(name) do
          [{^name, pid}] -> pid
          _ -> nil
        end
      end

      defp register(namespace), do: register(namespace, nil)
      defp register(namespace, params), do: register(namespace, UUID.uuid4(:hex), params)
      defp register(namespace, name, params) do
        Moongate.Core.Processes.register(namespace, name, params)
      end

      # A shortcut for {:noreply, state} that is easier to pipe into.
      defp reply(state, reply) do
        {:reply, reply, state}
      end

      defp tell(message, name) do
        pid = pid_for_name(name)
        Moongate.Core.Processes.tell_pid(message, pid)
      end
      defp tell(message, namespace, id) do
        pid = pid_for_name("#{namespace}_#{id}")
        Moongate.Core.Processes.tell_pid(message, pid)
      end

      defp tell_all(message, namespace) do
        case Moongate.Core.Processes.lookup("tree_#{namespace}") do
          [{^namespace, supervisor}] ->
            supervisor
            |> Supervisor.which_children
            |> Enum.map(&tell_pid(message, elem(&1, 1)))
          [] -> nil
        end
      end

      defp tell_pid(message, pid), do: Moongate.Core.Processes.tell_pid(message, pid)
    end
  end

  def all do
    :ets.match_object(:registry, {:_, :_})
  end

  def ask_pid(message, pid) do
    it = capabilities(pid)

    cond do
      it.can_be_called -> GenServer.call(pid, message)
      it.can_receive -> send(pid, message)
    end
  end

  def capabilities(pid) do
    if pid != nil do
      {mod, _, _} = Process.info(pid)[:dictionary][:"$initial_call"]

      %{
        can_be_called: mod.__info__(:functions)[:handle_call] == 3,
        can_be_cast_to: mod.__info__(:functions)[:handle_cast] == 2,
        can_receive: mod.__info__(:functions)[:receive_loop] == 1
      }
    else
      %{
        can_be_called: false,
        can_be_cast_to: false,
        can_receive: false
      }
    end
  end

  def drop_pid(pid) do
    results = :ets.match_object(:registry, {:_, pid})

    results
    |> Enum.map(fn({name, _}) ->
      :ets.delete(:registry, name)
    end)
    :ok
  end

  def insert(data) do
    :ets.insert(:registry, data)
  end

  def kill_pid(namespace, pid) do
    supervisor_name = "tree_#{namespace}"

    case Moongate.Core.Processes.lookup("tree_#{namespace}") do
      [{^supervisor_name, supervisor}] ->
        drop_pid(pid)
        :ok = Supervisor.terminate_child(supervisor, pid)
      [] -> nil
    end
  end

  def lookup(name) do
    :ets.lookup(:registry, name)
  end

  def of(namespace) do
    all
    |> Enum.filter(fn({name, _pid}) ->
      (name
       |> String.split("_")
       |> hd) == namespace
    end)
  end

  def register(namespace), do: register(namespace, nil)
  def register(namespace, params), do: register(namespace, UUID.uuid4(:hex), params)
  def register(namespace, name, params) do
    supervisor_name = "tree_#{namespace}"

    case :ets.lookup(:registry, supervisor_name) do
      [{^supervisor_name, supervisor}] ->
        {:ok, child} = Supervisor.start_child(supervisor, [params])
        insert({"#{namespace}_#{name}", child})
        tell_pid({:init}, child)
        child
      [] -> nil
    end
  end

  def tell_pid(message, pid) do
    it = capabilities(pid)

    if it.can_be_cast_to, do: GenServer.cast(pid, message)
    if it.can_receive, do: send(pid, message)
  end
end

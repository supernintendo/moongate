defmodule Moongate.Processes do
  def all do
    :ets.match_object(:registry, {:_, :_})
  end

  def ask_pid(message, pid) do
    it = capabilities(pid)

    if it.can_be_called, do: result = GenServer.call(pid, message)
    if it.can_receive, do: result = send(pid, message)

    result
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

    case Moongate.Processes.lookup("tree_#{namespace}") do
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
    |> Enum.filter(fn({name, pid}) ->
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

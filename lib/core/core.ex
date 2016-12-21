defmodule Moongate.Core do
  use Moongate.Env

  defmodule Iex do
    def about do
      Moongate.Core.about
      :timer.sleep(1)
    end

    def help do
      {:info, %{
        about: "View version and system information.",
        quit: "Terminate the server gracefully."
      }}
      |> Moongate.Core.log
    end

    def quit do
      Moongate.Core.quit
    end
  end

  defmodule Session do
    defmacro __using__(_) do
      session_module = Application.get_env(:moongate, :session)

      quote do
        import unquote(session_module)
      end
    end
  end

  @months {
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  }

  def about do
    Moongate.Core.log(:moongate_banner)
    IO.puts ""
  end

  def atom_to_string(value) do
    if is_atom(value) do
      parts = value
      |> Atom.to_string
      |> String.split(".")

      if (hd(parts) == "Elixir") do
        Enum.join(tl(parts), ".")
      else
        Enum.join(parts, ".")
      end
    else
      value
    end
  end

  def camelize(string) do
    string
    |> Inflex.camelize
  end

  def deed_module(module_name) do
    [
      world_name
      |> String.capitalize
      |> camelize
      |> String.to_atom, Deed, module_name
    ]
    |> Module.safe_concat
  end

  def formatted_time do
    {{year, month, day}, {hour, min, _sec}} = :calendar.local_time()

    "#{@months |> elem(month - 1)} #{day}, #{year} · #{hour}:#{min} "
  end

  def local_ip do
    {:ok, parts} = :inet.getif
    parts
    |> hd
    |> elem(0)
    |> Tuple.to_list
    |> Enum.join(".")
  end

  def log(message) do
    GenServer.cast(:logger, {:log, message})
  end

  def log(status, message) do
    GenServer.cast(:logger, {:log, status, message})
  end

  def handshake do
    %{
      ip: local_ip,
      rings: Moongate.ETS.index(:ring),
      version: Moongate.Application.version
    }
  end

  def has_function?(module, func_name) do
    :functions
    |> module.__info__
    |> Enum.any?(fn ({func, _arity}) ->
      "#{func}" == func_name
    end)
  end

  def module_to_string(module) do
    "#{module}"
    |> String.replace("Elixir.", "")
  end

  def quit do
    :init.stop
  end

  def world_apply(func) do
    apply(world_module, func, [])
  end
  def world_apply(args, func) do
    cond do
      is_list(args) -> apply(world_module, func, args)
      true -> world_apply([args], func)
    end
  end

  def world_directory do
    "worlds/#{world_name}"
  end

  def world_module do
    Module.safe_concat(camelize(world_name), "World")
  end
end

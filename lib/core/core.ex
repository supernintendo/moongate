defmodule Moongate.Core do
  @moduledoc """
  Provides core functionality and helper functions
  for the Moongate application server.
  """

  use Moongate.CoreEnv

  defmodule Iex do
    defmacro __using__(_) do
      commands_module = String.to_atom("#{Application.get_env(:moongate, :console)}Commands")

      if Code.ensure_loaded?(commands_module) do
        exports = commands_module.__info__(:exports)

        if List.keymember?(exports, :init_message, 0) do
          apply(commands_module, :init_message, [])
        end
        quote do
          import unquote(commands_module)
        end
      end
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

  # List of months, used by Moongate.Core.formatted_time/0
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

  @doc """
  Converts an atom into a string.

  ## Examples

  Regular atoms will be cast in the same manner
  as `Atom.to_string/1`:

      iex> Moongate.Core.atom_to_string(:zone)
      "zone"

  Module atom aliases will be returned without
  the "Elixir." prefix:

      iex> Moongate.Core.atom_to_string(Default.Zone.Level)
      "Default.Zone.Level"
  """
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

  @doc """
  Camelizes a string or an atom.

  ## Examples

      iex> Moongate.Core.camelize(:foo_bar)
      "FooBar"

      iex> Moongate.Core.camelize("lorem-ipsum")
      "LoremIpsum"
  """
  def camelize(value) do
    value
    |> Inflex.camelize
  end

  @doc """
  Returns the deed module for the current world
  when passed the last part of the module.

  ## Example

  The following example assumes that the current
  world name is "default":

      iex> Moongate.Core.deed_module(XY)
      Default.Deeds.XY
  """
  def deed_module(module_name) do
    [
      (world_name
      |> String.capitalize
      |> camelize
      |> String.to_atom),
      Deed,
      module_name
    ]
    |> Module.safe_concat
  end

  @doc """
  Returns a string representation of the current
  local time.

  ## Example

      iex> Moongate.Core.formatted_time
      "December 23, 2016 · 21:29"
  """
  def formatted_time do
    {{year, month, day}, {hour, min, _sec}} = :calendar.local_time()

    "#{@months |> elem(month - 1)} #{day}, #{year} · #{hour}:#{min}"
  end

  @doc """
  Returns a string representation of the IP address
  of the current node on the local network.

  ## Example

      iex> Moongate.Core.local_ip
      "10.11.12.1"
  """
  def local_ip do
    {:ok, parts} = :inet.getif
    parts
    |> hd
    |> elem(0)
    |> Tuple.to_list
    |> Enum.join(".")
  end

  @doc """
  Passes a message string to the logger GenServer, causing
  it to be printed by the logger defined by the current
  configuration. An atom can be passed as the second
  argument for logger messages that represent a status
  change (up / down).
  """
  def log(message) do
    GenServer.cast(:logger, {:log, message})
  end
  def log(message, status) do
    GenServer.cast(:logger, {:log, message, status})
  end

  @doc """
  Returns values which can be used by clients to establish a
  better understanding of the current Moongate instance and
  its properties.

  ## Example

      iex> Moongate.Core.handshake
      %{
        ip: "10.11.12.1",
        rings: %{
          "Player" => %{
            drift: :integer,
            origin: :origin,
            speed: :integer,
            x: :integer,
            y: :integer
          }
        },
        version: "1.1.0"
      }
  """
  def handshake do
    %{
      ip: local_ip,
      rings: Moongate.CoreETS.index(:ring),
      version: Moongate.version
    }
  end

  @doc """
  Checks whether or not a module exports a function
  by name.

  ## Example

      iex> Moongate.Core.has_function?(Moongate.Core, "has_function?")
      true

      iex> Moongate.Core.has_function?(Moongate.Core, "non_existent_function")
      false
  """
  def has_function?(module, func_name) do
    :functions
    |> module.__info__
    |> Enum.any?(fn ({func, _arity}) ->
      "#{func}" == func_name
    end)
  end

  @doc """
  Calls a function on the current world module. An
  argument or list of arguments can be passed as the
  first argument to Moongate.Core.world_apply/2 which
  will pass those arguments to the function on
  the world module.

  ## Example

  The following examples assume the current world name
  is "example" and that the world module exports the
  hypothetical functions `foo/0`, `foo/1` and `foo/2`,
  all of which return a string indicating that the
  function has been called (including any arguments
  that have been passed to the function):

      iex> Moongate.Core.world_apply(:foo)
      "foo/0 called"

      iex> Moongate.Core.world_apply("bar", :foo)
      "foo/1 called with argument bar

      iex> Moongate.Core.world_apply(["lorem ipsum"], :foo)
      "foo/2 called with arguments lorem, ipsum
  """
  def world_apply(func) do
    apply(world_module, func, [])
  end
  def world_apply(args, func) do
    cond do
      is_list(args) -> apply(world_module, func, args)
      true -> world_apply([args], func)
    end
  end

  @doc """
  Returns the world directory for the current
  world.

  ## Example

  Assuming the current world name is 'default':

      iex> Moongate.Core.world_directory
      "worlds/default"
  """
  def world_directory do
    "worlds/#{world_name}"
  end

  @doc """
  Returns the world module (main entry point module) for
  the current world.

  ## Example

  Assuming the current world name is 'default':

      iex> Moongate.Core.world_module
      Default.World
  """
  def world_module do
    Module.safe_concat(camelize(world_name), "World")
  end
end

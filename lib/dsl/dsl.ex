defmodule Moongate.DSL do
  defmodule Error do
    defexception message: "Unexpected DSL error"
  end
  alias Moongate.DSL.Terms

  def common do
    quote do
      import Exmorph
      import Terms.{
        Attach,
        Assign,
        Buffer,
        Command,
        Data,
        Echo,
        Error,
        Function,
        Log,
        Look,
        Handle,
        Retarget,
        Ping,
        Target,
        Trigger,
        Untarget,
        Void,
        Warn
      }
    end
  end

  def entities do
    quote do
      unquote(common())
      import Terms.{
        Create,
        Cure,
        Destroy,
        Peek,
        Purge,
        Select,
        Set
      }
    end
  end

  def game do
    quote do
      unquote(common())
      import Terms.{
        Fibers,
        Join,
        Leave,
        Zone
      }
    end
  end

  def zone do
    quote do
      unquote(entities())
      import Terms.{
        Fibers,
        Join,
        Leave,
        Rings,
        Save
      }
    end
  end

  def ring do
    quote do
      unquote(entities())
      import Terms.{
        Describe,
        Fibers,
        Morph,
        Rules
      }
    end
  end

  def rule do
    quote do
      unquote(common())
      unquote(entities())
      import Terms.{
        Describe,
        Morph
      }
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
  defmacro __using__(_) do
    raise Error, message: ~s(Bad argument passed to `use Moongate.DSL`.

      Possible options are:

      :game, :zone, :ring, :rule,
      :entities, :common
    )
  end
end

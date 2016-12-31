defmodule Moongate.Console.Commands do
  @commands %{
    about: "View version and system information.",
    quit: "Terminate the server gracefully."
  }

  @doc """
  Prints a graphical banner and version information.
  """
  def about do
    Moongate.Core.log(:moongate_banner)
  end

  @doc """
  Prints available Moongate console commands.
  """
  def help do
    Moongate.Core.log({:info, @commands})
  end

  @doc """
  Alias for &quit/0.
  """
  def exit, do: quit

  @doc """
  Requests that the support GenServer terminates Moongate
  gracefully.
  """
  def quit do
    GenServer.cast(:support, :quit)
  end
end
defmodule Moongate.DSL.Terms.Command do
  alias Moongate.{
    CoreEvent,
    CoreNetwork,
    DSL.Queue
  }

  defmodule Dispatcher do
    @packet Application.get_env(:moongate, :packet)

    def call({Command, command_name, args}, %CoreEvent{} = event) do
      @packet.factory.command(command_name, args)
      |> CoreNetwork.send_packet(event.targets)
      event
    end
  end

  def command(%CoreEvent{} = event, command_name) do
    command(event, command_name, [])
  end
  def command(%CoreEvent{} = event, command_name, args) when is_list(args) do
    {Command, command_name, args}
    |> Queue.push(event)
  end
  def command(%CoreEvent{} = event, command_name, arg) do
    command(event, command_name, [arg])
  end
  def command(%CoreEvent{} = event, command_name, arg, arg2) do
    command(event, command_name, [arg, arg2])
  end
end

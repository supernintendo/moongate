defmodule Moongate.Fibers.Client do
  alias Moongate.{
    Core,
    CoreConfig,
    CoreNetwork,
    CoreSupport
  }

  def start(%CoreConfig.Client{handler: handler_string} = config, parent) do
    with(
      handler <- Module.safe_concat([handler_string]),
      :ok <- apply(handler, :before_init, []),
      launch_command when is_bitstring(launch_command) <- apply(handler, :launch_command, [config]),
      proc when is_pid(proc) <- Port.open({:spawn, launch_command}, [:binary]),
      os_pid <- Port.info(proc)[:os_pid],
      :ok <- CoreSupport.trap_os_pid(os_pid),
      :ok <- apply(handler, :after_init, []),
      do: wait(%{
        handler: handler,
        parent: parent,
        proc: proc,
        os_pid: os_pid
      }))
  end

  def wait(state) do
    receive do
      {_port, {:data, "closed"}} ->
        process_killed(state)
      message ->
        case apply(state.handler, :handle, [message]) do
          :ok -> wait(state)
          _ -> process_killed(state)
        end
    end
  end

  defp process_killed(state) do
    Core.log({:fiber, "Fiber (#{inspect __MODULE__})"}, :down)
    CoreNetwork.kill_process({"fiber", state.parent})
    CoreSupport.untrap_os_pid(state.os_pid)
  end
end

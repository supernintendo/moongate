defmodule Moongate.Fibers.Generic do
  alias Moongate.{
    CoreBootstrap,
    CoreSupport
  }

  @game_path CoreBootstrap.game_path()

  def start(params, parent) do
    proc = Port.open({:spawn, "#{params.command}"}, [])
    os_pid = Port.info(proc)[:os_pid]
    CoreSupport.trap_os_pid(Core.uuid(:os_pid), os_pid)

    wait(%{
      parent: parent,
      proc: proc
    })
  end

  def wait(state) do
    receive do
      _ -> nil
    end
    wait(state)
  end
end

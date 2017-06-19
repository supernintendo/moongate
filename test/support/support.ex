defmodule Moongate.TestSupport do
  alias Moongate.Core

  def game_pids do
    %{
      ring: Core.pid({Board, Entity}),
      zone: Core.pid(Board)
    }
  end
end

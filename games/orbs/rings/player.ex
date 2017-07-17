defmodule Orbs.Player do
  use Moongate.DSL, :ring

  describe do
    %{
      {:x, Float} => :rand.uniform(),
      {:y, Float} => :rand.uniform()
    }
  end

  rules [
    Movement
  ]
end

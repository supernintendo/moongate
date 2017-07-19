defmodule Orbs.Player do
  use Moongate.DSL, :ring

  describe do
    %{
      {:x, Float} => :rand.uniform(),
      {:y, Float} => :rand.uniform(),
      {:speed, Integer} => Enum.random(150..350)
    }
  end

  rules [
    Movement
  ]
end

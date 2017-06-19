defmodule Orbs.Player do
  use Moongate.DSL, :ring

  describe do
    %{
      {:x, Integer} => 0,
      {:y, Integer} => 0,
      {:width, Integer} => 32,
      {:height, Integer} => 32
    }
  end

  rules [
    Movement
  ]
end

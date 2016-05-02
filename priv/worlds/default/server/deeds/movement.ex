defmodule Default.Deeds.Movement do
  import Moongate.Deed

  attributes %{
    direction: :string,
    speed: :float,
    x: :float,
    y: :float
  }
  transforms %{
    "move left" => {:sub, :x, :by, :speed},
    "move right" => {:add, :x, :by, :speed},
    "move up" => {:sub, :y, :by, :speed},
    "move down" => {:add, :y, :by, :speed},
    "move xreset" => {:cure, :x},
    "move yreset" => {:cure, :y},
    "move _" => nil,
    "turn" => {:set, :direction}
  }

  def move(entity, {x, y}) do
    entity
    |> transform("turn", x)
    |> transform("move #{x}")
    |> transform("move #{y}")
  end
end

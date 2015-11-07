defmodule Default.Pools.Character do
  import Moongate.Pool

  @move_transform %{
    mode: "linear",
    tag: "movement"
  }
  attributes %{
    name:       {:string, "a noob"},
    health:     {:int, 3},
    max_health: {:int, 3},
    speed:      {:float, 0.05},
    x:          {:float, 50.0},
    y:          {:float, 50.0}
  }
  conveys [
    {:refresh, {:every, 3000}},
    {:refresh, {:upon, Character, :init}},
    {:refresh, {:upon, Character, :move}}
  ]

  def move(event, params) do
    char = event.this
    blocked = is_blocked(char, params)

    if blocked, do: stopping(char), else: moving(char, params)
    bubble event, :move
  end

  def is_blocked(char, params) do
    false
  end

  def moving(char, {x_delta, y_delta}) do
    x_speed = attr(char, :speed) * x_delta
    y_speed = attr(char, :speed) * y_delta
    mutate char, :x, x_speed, @move_transform
    mutate char, :y, y_speed, @move_transform
  end

  def stopping(char) do
    mutate char, :x, 0, @move_transform
    mutate char, :y, 0, @move_transform
  end

  def refresh(event, _) do
    char = event.this
    chars = batch event, Character, [:name, :x, :y]
    tell char, chars
  end
end

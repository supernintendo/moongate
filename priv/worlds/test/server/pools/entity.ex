defmodule Test.Pools.Entity do
  import Moongate.Pool

  attributes %{
    float:  {:float, 0.0},
    int:    {:int, 0},
    string: {:string, "a string"}
  }
  cascades []
  touches []

  def set_int(event, {value}) do
    entity = event.this

    set(entity, :int, value)
  end

  def set_float(event, {value}) do
    entity = event.this

    set(entity, :float, value)
  end

  def set_string(event, {value}) do
    entity = event.this

    set(entity, :string, value)
  end
end

defmodule Test.Pools.Entity do
  import Moongate.Pool

  attributes %{
    float:  {:float, 0.0},
    int:    {:int, 0},
    string: {:string, "a string"}
  }
end

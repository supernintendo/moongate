defmodule Test.Ring.Entity do
  import Moongate.Ring

  attributes %{
    float:  {:float, 0.0},
    int:    {:int, 0},
    string: {:string, "a string"}
  }
end

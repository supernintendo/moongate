defmodule Default.Pools.Message do
  import Moongate.Pool
  attributes %{
    origin:       :origin,
    body:         {:string, ""},
  }
  deeds []
  public [:body]
end

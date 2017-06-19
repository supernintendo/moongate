defmodule Test.Entity do
  use Moongate.DSL, :ring

  describe do
    %{
      {:int, Integer} => 128,
      {:float, Float} => 32.0,
      {:string, String} => "hello"
    }
  end

  rules []
end

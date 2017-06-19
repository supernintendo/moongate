defmodule Test.Modify do
  use Moongate.DSL, :rule

  describe do
    %{
      int: Integer,
      float: Float,
      string: String
    }
  end
end

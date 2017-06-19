defmodule Moongate.DSL.Terms.DataTest do
  require Moongate.DSL.Terms.Data
  use ExUnit.Case

  test "&data/1" do
    assert Moongate.DSL.Terms.Data.data("/data/test.data.exs") == %{
      hello: "world",
      test: 42,
      foo: %{
        "bar" => true
      },
      baz: {:qux, [0, 0, 1, 0, 0]}
    }
  end
end

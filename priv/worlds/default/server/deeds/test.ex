defmodule Default.Deeds.Test do
  import Moongate.Deed

  attributes %{}

  def foo(this, params, event) do
    {:relay, "foo"}
  end

  def bar(this, params, event) do
    IO.puts "bar."
    {:ok}
  end
end

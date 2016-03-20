defmodule Default.Deeds.Test do
  import Moongate.Deed

  attributes %{}

  def foo(_this, _params, _event) do
    {:relay, "foo"}
  end

  def bar(_this, _params, _event) do
    IO.puts "bar."
    {:ok}
  end
end

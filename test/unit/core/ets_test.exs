defmodule Moongate.Tests.ETS do
  use ExUnit.Case, async: false
  alias Moongate.ETS

  test "&delete/1" do
    :ets.insert(:cache, {"delete_test", true})
    ETS.delete({:cache, "delete_test"})
    result = :ets.lookup(:cache, "delete_test")

    assert result == []
  end

  test "&lookup/1" do
    :ets.insert(:cache, {"lookup_test", "foo"})
    :ets.insert(:cache, {"lookup_test_2", "bar"})
    result = ETS.lookup({:cache, "lookup_test"})
    result_2 = ETS.lookup({:cache, "lookup_test_2"})

    assert result == [{"lookup_test", "foo"}]
    assert result_2 == [{"lookup_test_2", "bar"}]
  end

  test "&index/1" do
    :ets.insert(:cache, {"index_test", true})

    result = ETS.index(:cache)
    Enum.any?(result, &(&1 == {"index_test", true}))
  end

  test "&insert/3" do
    ETS.insert({:cache, "insert_test", true})
    ETS.insert({:cache, "insert_test_2", 42})
    result = :ets.lookup(:cache, "insert_test")
    result_2 = :ets.lookup(:cache, "insert_test_2")

    assert result == [{"insert_test", true}]
    assert result_2 == [{"insert_test_2", 42}]
  end
end
defmodule Moongate.CoreUtilityTest do
  use ExUnit.Case
  alias Moongate.CoreUtility

  test "&atom_to_string/1" do
    assert CoreUtility.atom_to_string(Moongate.CoreUtilityTest) == "Moongate.CoreUtilityTest"
    assert CoreUtility.atom_to_string(:game) == "game"
  end

  test "&camelize/1" do
    assert CoreUtility.camelize("corp-por") == "CorpPor"
    assert CoreUtility.camelize("corp_por") == "CorpPor"
    assert CoreUtility.camelize("in-por-yelm") == "InPorYelm"
    assert CoreUtility.camelize("in_por-yelm") == "InPorYelm"
    assert CoreUtility.camelize("an-ex-por") == "AnExPor"
    assert CoreUtility.camelize("an_ex_por") == "AnExPor"
  end

  test "&exports/1" do
    assert CoreUtility.exports?(CoreUtility, :exports?)
    refute CoreUtility.exports?(CoreUtility, :void)
  end

  test "&ls_recursive/1" do
    contents = CoreUtility.ls_recursive("test/support/game")
    [
      "test/support/game/game.ex",
      "test/support/game/moongate.json",
      "test/support/game/rings/entity.ex",
      "test/support/game/zones/board.ex"
    ]
    |> Enum.all?(&(Enum.member?(contents, &1)))
  end
end

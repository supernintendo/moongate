defmodule Mage.Stage.Level do
  import Moongate.Stage

  meta %{}
  pools %{
    characters: Mage.Pools.Characters,
    tiles: Mage.Pools.Tiles
  }
  # takes :move, move_character: [:tiles]

  defp enrolled(t) do
    # origin = t.origin

    # if origin.trusted do
    #   publish(origin, :characters)
    #   subscribe(origin, :tiles)
    #   :ok
    # else
    #   {:error, "User is not logged in."}
    # end
  end

  def move_character(t) do
    # arrange(:move_to, %{
    #   pool: :character,
    #   subject: :is
    # })
  end
end
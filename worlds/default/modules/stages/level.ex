defmodule Default.Stage.Level do
  import Moongate.Stage

  meta %{}
  pools %{
    # characters: Default.Pools.Characters,
    tiles: Default.Pools.Tiles
  }
  # takes :move, move_character: [:tiles]

  def joined(_) do
    # origin = t.origin

    # if origin.trusted do
    #   publish(origin, :characters)
    #   subscribe(origin, :tiles)
    #   :ok
    # else
    #   {:error, "User is not logged in."}
    # end
  end

  def move_character(_) do
    # arrange(:move_to, %{
    #   pool: :character,
    #   subject: :is
    # })
  end
end
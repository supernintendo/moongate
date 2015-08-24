defmodule Default.Pools.Characters do
  import Moongate.Pool

  aspects %{
    name: {:string, :all},
    health: {:float, [:is, :can_see]},
    mana: {:int, [:is, :can_see]},
    x: {:int, [:is, :can_see]},
    y: {:int, [:is, :can_see]},
    damage: {:float, :is},
    exp: {:int, :is},
    visibility: :int,
    stealth: :int,
    slow: :int
  }

  # #
  # ### Transforms
  # #

  # # Character is hurt by an enemy.
  # defp settle({character, :hurt_by, enemy}) do
  #   alter {character, :health, prop(character :health) - prop(enemy, :damage), :immediately}
  # end

  # # Move a character to a tile.
  # defp settle({character, :move_to, tile}) do
  #   verifies character, :is_next_to, tile
  #   verifies :targets_legal, tile

  #   alter {character,
  #           [:x, :y],
  #           [prop(tile, :x), prop(tile, :y)],
  #           {:linear, prop(character, :slow), :seconds},
  #           {:focalize, 4}}
  # end

  # # #
  # # ### Verifies
  # # #
  # defp verify({character, :is_next_to, target}) do
  #   [x, y] = props(character, [:x, :y])
  #   [x2, y2] = props(target, [:x, :y])

  #   ((x == x2 - 1) || (x == x2 + 1) and (y == y2 - 1) || (y == y2 + 1))
  # end

  # # # Verify one character is close enough to see the other character.
  # defp verify({observer, :can_see, target}) do
  #   [x, y, visibility] = props(observer, [:x, :y, :visibility])
  #   [x2, y2, stealth] = props(target, [:x, :y, :stealth])

  #   ((x - visibility > x2 + stealth) and
  #     (x + visibility < x2 - stealth) and
  #     (y - visibility > y2 + stealth) and
  #     (y + visibility < y2 - stealth))
  # end

  # # Verify the target is not an obstacle.
  # defp verify({character, :targets_legal, target}) do
  #   prop(target, :type) != :obstacle
  # end
end
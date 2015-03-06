local Pool = require 'game.network.pool'

pools = {
  entities = Pool:new({"id", "x", "y", "last_x", "last_y"}),
  map = Pool:new({"id", "x", "y", "image"})
}

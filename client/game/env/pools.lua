local Pool = require 'game.network.pool'

pools = {
  entities = Pool:new({"id", "x", "y"}),
  map = Pool:new({"id", "x", "y", "image"})
}

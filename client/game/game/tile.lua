local Tile = class('Tile')

function Tile:initialize(x, y, parent)
  self.x = x
  self.y = y
  self.parent = parent
end

function Tile:draw()
  if self.image then
    love.graphics.draw(
      self.image,
      self.x * self.parent.spaceX,
      self.y * self.parent.spaceY
    )
  end
end

return Tile
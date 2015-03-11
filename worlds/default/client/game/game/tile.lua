local Tile = class('Tile')

function Tile:initialize(params, parent)
  self.x = params.x
  self.y = params.y
  self.image = params.image
  self.fadeInSpeed = 8
  self.parent = parent
  self.alpha = 0
end

function Tile:draw()
  if self.image then
    if self.alpha < 255 then
      self:fadeIn()
    end

    love.graphics.setColor(255, 255, 255, self.alpha)
    love.graphics.draw(
      IMAGES[self.image],
      self.x * self.parent.spaceX,
      self.y * self.parent.spaceY
    )
  end
end

function Tile:fadeIn()
  if self.alpha + self.fadeInSpeed > 128 then self.alpha = 128
  else self.alpha = self.alpha + self.fadeInSpeed end
end

return Tile
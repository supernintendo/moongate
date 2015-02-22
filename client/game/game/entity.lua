local Entity = class('Entity')

function Entity:initialize(params, parent)
  self.x = params.x
  self.y = params.y
  self.fadeInSpeed = 8
  self.parent = parent
  self.image = IMAGES["human"]
  self.alpha = 0
end

function Entity:draw()
  if self.image then
    if self.alpha < 255 then
      self:fadeIn()
    end

    love.graphics.setColor(255, 255, 255, self.alpha)
    love.graphics.draw(
      self.image,
      self.x * self.parent.spaceX,
      self.y * self.parent.spaceY
    )
  end
end

function Entity:fadeIn()
  if self.alpha + self.fadeInSpeed > 255 then self.alpha = 255
  else self.alpha = self.alpha + self.fadeInSpeed end
end

return Entity
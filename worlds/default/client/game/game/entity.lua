local Entity = class('Entity')

function Entity:initialize(params, parent)
  self.x = params.x
  self.y = params.y
  self.fadeInSpeed = 8
  self.parent = parent
  self.image = IMAGES[params.image]
  self.moveTweenX = Tween:new(params.x * self.parent.spaceX, params.x * self.parent.spaceX, 8)
  self.moveTweenY = Tween:new(params.y * self.parent.spaceY, params.y * self.parent.spaceY, 8)
  self.alpha = 0
end

function Entity:draw()
  if self.updated then
    self.moveTweenX:assign(self.last_x * self.parent.spaceX, self.x * self.parent.spaceX, 8)
    self.moveTweenY:assign(self.last_y * self.parent.spaceY, self.y * self.parent.spaceY, 8)
    self.updated = false
  end

  if self.image then
    if self.alpha < 255 then
      self:fadeIn()
    end

    love.graphics.setColor(255, 255, 255, self.alpha)
    love.graphics.draw(
      self.image,
      self.moveTweenX.value,
      self.moveTweenY.value
    )
  end

  self.moveTweenX:tick()
  self.moveTweenY:tick()
end

function Entity:fadeIn()
  if self.alpha + self.fadeInSpeed > 255 then self.alpha = 255
  else self.alpha = self.alpha + self.fadeInSpeed end
end

return Entity
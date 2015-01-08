local Overlay = class('Overlay')

function Overlay:initialize(image, x, y)
  if type(image) == 'string' then
    self.image = love.graphics.newImage(image)
  else
    self.image = image
  end

  self.alpha = 255
  self.x = x
  self.y = y
  self.scaleX = 1
  self.scaleY = 1
  self.width = self.image:getWidth()
  self.height = self.image:getHeight()
end

function Overlay:draw()
  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(255, 255, 255, self.alpha)
  love.graphics.scale(self.scaleX, self.scaleY)
  love.graphics.draw(self.image, self.x, self.y)
  self:tick()
end

function Overlay:tick()
end

return Overlay

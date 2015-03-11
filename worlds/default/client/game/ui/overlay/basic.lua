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
  love.graphics.setBlendMode('alpha')
  love.graphics.setColor(255, 255, 255, self.alpha)
  love.graphics.scale(self.scaleX, self.scaleY)
  love.graphics.draw(
    self.image,
    self:mutatePos('x', self.x),
    self:mutatePos('y', self.y)
  )
  self:tick()
end

function Overlay:mutatePos(type, pos)
  if pos == 'center' then
    if type == 'x' then
      return (DIMENSIONS.w / 2) - (self:getWidth() / 2)
    elseif type == 'y' then
      return DIMENSIONS.h / 2 -- + (self.image:getHeight() / 2)
    end
  else
    return pos
  end
end

function Overlay:getHeight()
  return self.image:getHeight()
end

function Overlay:getWidth()
  return self.image:getWidth()
end

function Overlay:tick()
end

return Overlay

local AnimatedOverlay = class('AnimatedOverlay', Overlay)

function AnimatedOverlay:initialize(file, x, y, loop)
  local json = Helper:readJSON(file)
  self.image = love.graphics.newImage('assets/' .. json.meta.image)
  self.animation = Animation:new(json)
  Overlay.initialize(self, self.image, x, y) -- Superclass initializer
end

function AnimatedOverlay:tick()
  self.animation:tick()
end

function AnimatedOverlay:draw()
  love.graphics.setBlendMode('alpha')
  love.graphics.setColor(255, 255, 255, self.alpha)
  love.graphics.scale(self.scaleX, self.scaleY)
  love.graphics.draw(
    self.image,
    self.animation:getCurrentFrame(),
    self:mutatePos('x', self.x),
    self:mutatePos('y', self.y)
  )
  self:tick()
end

function AnimatedOverlay:getWidth()
  return self.animation:getWidth()
end

return AnimatedOverlay

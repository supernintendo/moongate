local Animation = class('Animation')

function Animation:initialize(json)
  local count = 0
  self.hash = json
  self.frames = {}

  for i, sprite in ipairs(self.hash.frames) do
    self.frames[i] = love.graphics.newQuad(
      sprite.frame.x,
      sprite.frame.y,
      sprite.frame.w,
      sprite.frame.h,
      self.hash.meta.size.w,
      self.hash.meta.size.h
    )
    count = count + 1
  end

  self.currentFrame = 1
  self.currentTick = 0
  self.interval = self.hash.meta.speed
  self.loop = self.hash.meta.loop
  self.frameCount = count
end

function Animation:getCurrentFrame()
  return self.frames[self.currentFrame]
end

function Animation:getFrame(frame)
  return self.frames[frame]
end

function Animation:getHeight()
  return self.hash.frames[self.currentFrame].frame.h
end

function Animation:getWidth()
  return self.hash.frames[self.currentFrame].frame.w
end

function Animation:incrementFrame()
  if self.currentFrame >= self.frameCount then
    if self.loop then
      self.currentFrame = 1
    end
  else
    self.currentFrame = self.currentFrame + 1
  end
end

function Animation:tick()
  self.currentTick = self.currentTick + 1

  if self.currentTick >= self.interval then
    self:incrementFrame()
    self.currentTick = 0
  end
end

return Animation

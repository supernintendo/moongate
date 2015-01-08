local MouseState = class('MouseState')

function MouseState:initialize()
  mouseX = 0
  mouseY = 0

  self.cursors = {
    default = love.mouse.getSystemCursor("arrow"),
    ibeam = love.mouse.getSystemCursor("ibeam")
  }
  self.active = {
    ibeam = 0
  }
end

function MouseState:tick()
  mouseX = love.mouse.getX()
  mouseY = love.mouse.getY()

  if self.active.ibeam > 0 then
    love.mouse.setCursor(self.cursors.ibeam)
  else
    love.mouse.setCursor(self.cursors.default)
  end
end

return MouseState

local MouseRange = class('MouseRange')

function MouseRange:initialize(parent, cursor, padLeft, padTop, padRight, padBottom)
  self.disabled = false
  self.hover = false
  self.left = parent.x + padLeft
  self.right = parent.x + parent.width - padRight
  self.top = parent.y + padTop
  self.bottom = parent.y + parent.height - padBottom
  self.cursor = cursor
  self.parent = parent
end

function MouseRange:checkForClick()
  if self.hover then
    if love.mouse.isDown('l') and not self.parent.clicked then
      self.parent:click()
    elseif not love.mouse.isDown('l') and self.parent.clicked then
      self.parent:unclick()
    end
  elseif love.mouse.isDown('l') then
    self.parent:clickOff()
  end
end

function MouseRange:checkForHover()
  if (mouseX > self.left and mouseX < self.right and
      mouseY > self.top and mouseY < self.bottom) then
    if not self.hover then
      self:setActive(true)
    end
  else
    if self.hover then self:setActive(false) end
  end
end

function MouseRange:disable()
  self.disabled = true
  self.hover = false
  self:setActive(false)
end

function MouseRange:setActive(state)
  if state then
    self.hover = true
    MouseState.active[self.cursor] = MouseState.active[self.cursor] + 1
  else
    self.hover = false
    MouseState.active[self.cursor] = MouseState.active[self.cursor] - 1
  end
end

function MouseRange:tick()
  if self.disabled then return false end

  self:checkForHover()
  self:checkForClick()

  return self.hover
end

return MouseRange
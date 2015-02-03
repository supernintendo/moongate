local TextOverlay = class('TextOverlay', Overlay)

function TextOverlay:initialize(placeholder, x, y, mask)
  self.font = love.graphics.newFont('assets/font.ttf', 12)
  self.active = false
  self.disabled = false
  self.hovered = false
  self.value = ''

  self.placeholder = placeholder
  self.mask = mask
  self.text = placeholder or self.value
  self.x = x
  self.y = y

  if placeholder then
    self.clearFirst = true
  end
  self:updateDimensions()
end

function TextOverlay:append(input)
  self.value = self.value .. input
  self:updateText()
end

function TextOverlay:backspace()
  self.value = string.sub(self.value, 1, -2)
  self:updateText()
end

function TextOverlay:disable()
  self.disabled = true
  self.active = false
  self.hovered = false
end

function TextOverlay:draw()
  love.graphics.setFont(self.font)
  love.graphics.setColor(self:getColorForState())
  love.graphics.print(self.text, self:mutatePos('x', self.x), self:mutatePos('y', self.y))
end

function TextOverlay:entry()
  if self.clearFirst then
    self.text = self.value
    self.clearFirst = false
  end

  self.active = true
end

function TextOverlay:getColorForState()
  if self.active then return 255, 255, 255, 195
  elseif self.disabled then return 255, 255, 255, 0
  elseif self.hovered then return 125, 125, 125, 145
  else return 125, 125, 125, 125 end
end

function TextOverlay:getHeight()
  return self.font:getHeight(self.text)
end

function TextOverlay:getWidth()
  return self.font:getWidth(self.text)
end

function TextOverlay:hover(state)
  if self.active then
    self.hovered = false
  else
    self.hovered = state
  end
end

function TextOverlay:stopEntry()
  if self.text == '' then
    self.text = self.placeholder
    self.clearFirst = true
  end

  self.active = false
end

function TextOverlay:updateDimensions()
  self.height = self.font:getHeight(self.text)
  self.width = self.font:getWidth(self.text)
end

function TextOverlay:updateText()
  if self.mask then
    self.text = string.rep('*', string.len(self.value))
  else
    self.text = self.value
  end
  self:updateDimensions()
end

return TextOverlay

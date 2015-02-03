local MouseRange = require 'game.ui.listener.mouserange'
local Input = class('Input', Overlay)

function Input:initialize(parentScene, image, x, y, textOverlay, submitEvent)
  Overlay.initialize(self, image, x, y) -- Superclass initializer 
  self.parentScene = parentScene
  self.active = false
  self.disabled = false
  self.textOverlay = textOverlay
  self.mouseRange = MouseRange:new(self, 'ibeam', 5, 0, 10, 5)
  self.submitEvent = submitEvent
end

function Input:tick()
  self.textOverlay:draw()

  if self.disabled then
    self.mouseRange:disable()
    self.textOverlay:disable()
  end
  if self.active and not self.disabled then self:captureEntry() end
  if self.mouseRange:tick() and not self.disabled then self.textOverlay:hover(true)
  else self.textOverlay:hover(false) end
end

function Input:captureEntry()
  entry = KeyState:poll()

  if entry == 'backspace' then
    self.textOverlay:backspace()
  elseif entry == 'return' then
    self.parentScene:captureInputEvent(self.submitEvent, self)
  elseif entry then
    self.textOverlay:append(entry)
  end
end

function Input:click()
  self.clicked = true
  self.active = true
  self.textOverlay:entry()
end

function Input:clickOff()
  self.active = false
  self.textOverlay:stopEntry()
end

function Input:unclick()
  self.clicked = false
end

return Input

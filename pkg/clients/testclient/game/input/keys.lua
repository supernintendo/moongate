local KeyState = class('KeyState')

function KeyState:initialize()
  self:ready('', false)
end

function KeyState:enter(key)
  self:ready(key, true)
end

function KeyState:keyPress(key)
  if key == "backspace" then self:ready(key, true)
  elseif key == "return" then self:ready(key, true)
  elseif key == "tab" then self:ready(key, true) end
end

function KeyState:poll()
  if self.pending then
    self.pending = false
    return self.entry
  else
    return false
  end
end

function KeyState:ready(key, state)
  self.entry = key
  self.pending = state
end

return KeyState

local Tween = class('Tween')

function Tween:initialize(from, to, rate)
  self:assign(from, to, rate)
end

function Tween:assign(from, to, rate)
  self.to = to
  self.rate = rate
  self.value = from

  if from < to then
    self.rate = rate
  else
    self.rate = rate * -1
  end
end

function Tween:tick()
  if self:tweenExceeds() then
    self.value = self.to
    return false
  else
    self.value = self:tweenedValue()
    return true
  end
end

function Tween:tweenExceeds()
  if self.value < self.to and self:tweenedValue() > self.to then
    return true
  elseif self.value > self.to and self:tweenedValue() < self.to then
    return true
  elseif self.value == self.to then
    return true
  else
    return false
  end
end

function Tween:tweenedValue()
  return self.value + self.rate
end

return Tween
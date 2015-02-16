local EntityState = class('EntityState')

function EntityState:initialize()
  self.contents = {}
  self.update = false
end

function EntityState:receive(packet)
  if packet.cast == "update" then
    self:updateEntities(packet.value)
  end
end

function EntityState:updateEntities(value)
  print(inspect(value))
  self.update = true
end

return EntityState
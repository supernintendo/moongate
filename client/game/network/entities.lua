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
  partials = {}
  entities = {}

  for partial in string.gmatch(value, '([^|]+)') do
    table.insert(partials, partial)
  end

  for i, partial in ipairs(partials) do
    local id = nil
    local x = nil
    local y = nil

    for attribute in string.gmatch(partial, '([^;]+)') do
      if not id then id = attribute
      elseif not x then x = attribute
      elseif not y then y = attribute
      end
      if id and x and y then
        table.insert(entities, {
          id = id,
          x = x,
          y = y
        })
      end
    end
  end

  self.contents = entities
  self.update = true
end

return EntityState
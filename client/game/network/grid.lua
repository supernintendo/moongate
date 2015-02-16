local GridState = class('GridState')

function GridState:initialize()
  self.contents = {}
  self.update = false
end

function GridState:receive(packet)
  if packet.cast == "update" then
    self:updateGrid(packet.value)
  end
end

function GridState:updateGrid(value)
  partials = {}
  map = {}

  for partial in string.gmatch(value, '([^|]+)') do
    table.insert(partials, partial)
  end

  for i, partial in ipairs(partials) do
    local x = nil
    local y = nil

    for attribute in string.gmatch(partial, '([^;]+)') do
      if not x then x = attribute
      elseif not y then y = attribute
      else
        map["tile_" .. x .. '_' .. y] = attribute
      end
    end
  end

  self.contents = map
  self.update = true
end

return GridState

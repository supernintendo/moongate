local Worlds = class('Worlds')

function Worlds:initialize()
  self.worldsFetched = false
  self.worlds = {}
end

function Worlds:receive(packet)
  if packet.cast == 'info' then self:assignInfo(packet.value) end
end

function Worlds:assignInfo(info)
  key,
  name,
  parsed = {}
  worldPairs = {}

  pairStart = true
  for pair in string.gmatch(info, '([^|]+)') do
    for value in string.gmatch(pair, '([^;]+)') do
      if pairStart then
        key = value
        pairStart = false
      else
        name = value
        pairStart = true
      end
    end

    worldPairs[key] = {
      id = key,
      name = name
    }
  end

  self.worlds = worldPairs
  self.worldsFetched = true
end

return Worlds

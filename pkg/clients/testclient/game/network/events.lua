local NetworkEvents = class('NetworkEvents')

function NetworkEvents:initialize() end

-- Given a packet, parse the packet and relay it.
function NetworkEvents:receivePacket(packet)
  local parsed = self:parsePacket(packet)
  -- print("Receiving message:" .. inspect(parsed))

  if parsed.namespace == 'auth' then Auth:receive(parsed) end
  if parsed.namespace == 'worlds' then Worlds:receive(parsed) end
end

-- Given a packet, return a table containing the packet's contents.
function NetworkEvents:parsePacket(packet)
  local parsed = {}

  for key, value in string.gmatch(packet, '(%w+)=([%w%s%!%.%_%;%|]+)') do
    parsed[key] = value
  end

  return parsed
end

return NetworkEvents

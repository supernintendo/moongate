local NetworkEvents = class('NetworkEvents')

function NetworkEvents:initialize()
end

function NetworkEvents:receivePacket(packet)
  local parsed = self:parsePacket(packet)
  -- print("Receiving message:" .. inspect(parsed))

  if parsed.namespace == "auth" then Auth:receive(parsed) end
  if parsed.namespace == "worlds" then Worlds:receive(parsed) end
end

function NetworkEvents:parsePacket(packet)
  local parsed = {}

  for key, value in string.gmatch(packet, "(%w+)=([%w%s%!%.%_%;%|]+)") do
    parsed[key] = value
  end

  return parsed
end

return NetworkEvents

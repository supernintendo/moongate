local NetworkEvents = class('NetworkEvents')

function NetworkEvents:initialize()
  self.stack = {}
end

function NetworkEvents:tick()
  local s, status, partial = TCP.socket:receive()

  if partial ~= '' then
    self:receivePacket(partial)
  end

  if #self.stack > 0 then
    self:processPacket(self.stack[#self.stack])
    table.remove(self.stack, #self.stack)
  end
end

-- Given a packet, parse the packet and relay it.
function NetworkEvents:receivePacket(packet)
  local parsed = self:parsePacket(packet)
end

-- Given a packet, return a table containing the packet's contents.
function NetworkEvents:parsePacket(packet)
  local group = {}
  local parsed = {}

  for key, value in string.gmatch(packet, '(%w+)=([%w%s%!%.%_%;%|]+)') do
    parsed[key] = value

    if key == "end" then
      table.insert(group, parsed)
      parsed = {}
    end
  end

  for i, item in ipairs(group) do
    table.insert(self.stack, item)
  end
end

function NetworkEvents:processPacket(packet)
  if packet.namespace == 'auth' then Auth:receive(packet)
  elseif packet.namespace == 'sessions' then Sessions:receive(packet)
  elseif pools[packet.namespace] then pools[packet.namespace]:receive(packet) end
end

return NetworkEvents

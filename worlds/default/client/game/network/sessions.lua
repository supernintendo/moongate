local Sessions = class('Sessions')

function Sessions:initialize()
  self.sessionsFetched = false
  self.sessions = {}
end

function Sessions:receive(packet)
  if packet.cast == 'info' then self:assignInfo(packet.value) end
end

function Sessions:assignInfo(info)
  key,
  name,
  parsed = {}
  sessionPairs = {}

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

    sessionPairs[key] = {
      id = key,
      name = name
    }
  end

  self.sessions = sessionPairs
  self.sessionsFetched = true
end

return Sessions

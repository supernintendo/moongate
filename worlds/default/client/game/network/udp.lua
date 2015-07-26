local UDP = class('UDP')

function UDP:initialize()
  self.socket = socket.udp()
  self.socket:setsockname('*', PORT)
end

function UDP:listen()
  self.socket:settimeout(0)
  self.socket:setpeername(ADDRESS, PORT)
end

function UDP:send(message)
  self.socket:send('begin' .. ' ' .. authToken .. ' ' .. message .. ' ' .. 'end')
end

return UDP

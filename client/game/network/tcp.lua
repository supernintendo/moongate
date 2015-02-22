local TCP = class('TCP')

function TCP:initialize()
  self.socket = socket.tcp()
end

function TCP:listen()
  self.socket:connect(ADDRESS, PORT)
  self.socket:settimeout(0)
end

function TCP:send(message)
  self.socket:send('begin' .. ' ' .. authToken .. ' ' .. message .. ' ' .. 'end')
end

return TCP

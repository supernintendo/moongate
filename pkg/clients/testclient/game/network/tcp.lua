local TCP = class('TCP')

function TCP:initialize()
  self.socket = socket.tcp()
end

function TCP:listen()
  self.socket:connect(ADDRESS, PORT)
  self.socket:settimeout(0)
end

function TCP:send(message)
  -- print('Sending message: ' .. authToken .. ' ' .. message)
  self.socket:send(authToken .. ' ' .. message)
end

return TCP

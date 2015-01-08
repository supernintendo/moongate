local Auth = class('Auth')

function Auth:initialize()
end

function Auth:receive(packet)
  if packet.cast == "set_token" then authToken = packet.value end
end

return Auth

require 'game.env.constants'
require 'game.env.globals'

local loginScreen = (require 'game.scenes.login'):new()
local area = (require 'game.scenes.area'):new()

function love.load()
  -- Listen for new messages from the server
  TCP:listen()
end

function love.draw()
  loginScreen:draw()
  MouseState:tick()
  local s, status, partial = TCP.socket:receive()

  if partial ~= "" then
    NetworkEvents:receivePacket(partial)
  end

  if loginScreen.done and not area.started then
    area:start()
  end
  if area.started then area:draw() end
end

function love.keypressed(key)
  KeyState:keyPress(key)
end

function love.textinput(t)
  KeyState:enter(t)
end

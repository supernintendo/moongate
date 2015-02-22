require 'game.env.constants'
require 'game.env.globals'
require 'game.env.images'

local scenes = {
  login = Scene:new('login'),
  game = Scene:new('game')
}

function love.load()
  -- Listen for new messages from the server
  TCP:listen()
end

function love.draw()
  scenes[currentScene]:tick()
  tick()
end

function love.keypressed(key)
  KeyState:keyPress(key)
end

function love.textinput(t)
  KeyState:enter(t)
end

function tick()
  -- Non drawing related tick events.
  MouseState:tick()
  NetworkEvents:tick()

  love.window.setTitle('Moongate - ' .. currentScene .. ' (' .. love.timer.getFPS() .. ' fps)')
end
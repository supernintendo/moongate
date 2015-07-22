require 'game.env.deps'
require 'game.env.classes'
require 'game.env.constants'
require 'game.env.globals'
require 'game.env.images'
require 'game.env.pools'
require 'game.env.singletons'

function love.load()
  -- Listen for new messages from the server
  Network:listen()
end

function love.draw()
  -- Create the scene if it doesn't exist.
  if not scenes[currentScene] then
    scenes[currentScene] = Scene:new(currentScene)
  end

  -- Non drawing related tick events.
  MouseState:tick()
  NetworkEvents:tick()

  -- Tick the scene
  scenes[currentScene]:tick()
  love.window.setTitle('Moongate - ' .. currentScene .. ' (' .. love.timer.getFPS() .. ' fps)')
end

function love.keypressed(key)
  KeyState:keyPress(key)
end

function love.textinput(t)
  KeyState:enter(t)
end
local Game = class('Game')

function Game:initialize(parent)
  love.keyboard.setKeyRepeat(true)
  self.parent = parent
end

function Game:tick()
  function love.keypressed(key)
    Network:send('game key ' .. ' ' .. key)
  end
end

return Game
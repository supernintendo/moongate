local Game = class('Game')

function Game:initialize(parent)
  self.parent = parent
end

function Game:tick()
  function love.keypressed(key)
    TCP:send('game key ' .. ' ' .. key)
  end
end

return Game
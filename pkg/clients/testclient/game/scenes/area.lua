local area = class('Area')

function area:initialize()
  self.started = false
end

function area:start()
  self.started = true
end

function area:draw()
  print "time for a game"
end

return area
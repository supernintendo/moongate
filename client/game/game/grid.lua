local Grid = class('Grid')

function Grid:initialize(height, width, spaceX, spaceY, watchers)
  self.height = height
  self.width = width
  self.offsetX = 0
  self.offsetY = 0
  self.spaceX = spaceX
  self.spaceY = spaceY

  self.layers = {}
  self.watchers = watchers
end

function Grid:checkPoolsForUpdates()
  for i, watcher in ipairs(self.watchers) do
    if pools[watcher[1]] and pools[watcher[1]].update then
      self:updateFromPool(watcher, pools[watcher[1]].contents)
      pools[watcher[1]].update = false
    end
  end
end

function Grid:draw()
  self:checkPoolsForUpdates()

  for i, watcher in ipairs(self.watchers) do
    if self.layers[watcher[1]] then
      for id, instance in pairs(self.layers[watcher[1]]) do
        instance:draw()
      end
    end
  end
end

function Grid:updateFromPool(watcher, contents)
  local poolName, class, key = unpack(watcher)

  for i, instance in ipairs(contents) do
    if not self.layers[poolName] then self.layers[poolName] = {} end
    if self.layers[poolName][instance[key]] then
      for attribute, value in pairs(instance) do
        self.layers[poolName][instance[key]][attribute] = value
      end
    else
      self.layers[poolName][instance[key]] = _G[class]:new(instance, self)
    end
  end
end

return Grid
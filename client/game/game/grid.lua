local Grid = class('Grid')

function Grid:initialize(height, width, spaceX, spaceY, subs)
  self.height = height
  self.width = width
  self.offsetX = 0
  self.offsetY = 0
  self.spaceX = spaceX
  self.spaceY = spaceY

  self.entities = {}
  self.tiles = {}
  self.subs = subs
  self:createTiles()
end

function Grid:checkGridStateForUpdates()
  if GridState.update then
    self:updateFromContents(GridState.contents)
    GridState.update = false
  end
end

function Grid:checkSubsForUpdates()
  for i, sub in ipairs(self.subs) do
    if pub[sub] and pub[sub].update then
      self:updateFromSub(sub, pub[sub].contents)
      pub[sub].update = false
    end
  end
end

function Grid:createTiles()
  local tiles = {}

  for row = 0, self.height - 1 do
    for column = 0, self.width - 1 do
      tiles['tile_' .. column .. '_' .. row] = Tile:new(column, row, self)
    end
  end

  self.tiles = tiles
end

function Grid:draw()
  self:checkGridStateForUpdates()
  self:checkSubsForUpdates()

  for key, tile in pairs(self.tiles) do
    tile:draw()
  end

  for key, entity in pairs(self.entities) do
    entity:draw()
  end
end

function Grid:updateFromContents(contents)
  for row = 0, self.height - 1 do
    for column = 0, self.width - 1 do
      local tile = contents['tile_' .. (column + self.offsetX) .. '_' .. (row + self.offsetY)]

      if tile then
        self.tiles['tile_' .. column .. '_' .. row].image = IMAGES[tile]
      end
    end
  end
end

function Grid:updateEntities(contents)
  for i, entity in ipairs(contents) do
    if self.entities[entity.id] then
      self.entities[entity.id].x = entity.x
      self.entities[entity.id].y = entity.y
    else
      self.entities[entity.id] = Entity:new(entity.x, entity.y, self)
    end
  end
end

function Grid:updateFromSub(sub, contents)
  if sub == "entities" then
    self:updateEntities(contents)
  end
end

return Grid
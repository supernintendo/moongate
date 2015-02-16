local Grid = class('Grid')

function Grid:initialize(height, width, spaceX, spaceY)
  self.offsetX = 0
  self.offsetY = 0
  self.spaceX = spaceX
  self.spaceY = spaceY
  self.height = height
  self.width = width
  self.tiles = {}
  self:createTiles()
end

function Grid:checkGridStateForUpdates()
  if GridState.update then
    self:updateFromContents(GridState.contents)
    GridState.update = false
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

  for key, tile in pairs(self.tiles) do
    tile:draw()
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

return Grid
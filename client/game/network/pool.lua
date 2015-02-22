local Pool = class('Pool')

function Pool:initialize(args)
  self.contents = {}
  self.args = args
end

function Pool:receive(packet)
  if packet.cast == "update" then
    self:updateContents(packet.value)
  end
end

function Pool:updateContents(value)
  items = {}
  results = {}

  for item in string.gmatch(value, '([^|]+)') do
    table.insert(items, item)
  end

  for i, item in ipairs(items) do
    args = {}
    c = 1

    for attribute in string.gmatch(item, '([^;]+)') do
      args[self.args[c]] = attribute
      c = c + 1
    end

    table.insert(results, args)
  end

  self.contents = results
  self.update = true
end

return Pool
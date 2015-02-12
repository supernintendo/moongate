local Helper = class('Helper')

function Helper:readFile(filename)
  local file = io.open(filename, 'rb')
  local content = file:read('*all')
  file:close()

  return content
end

function Helper:readJSON(filename)
  return JSON.decode(Helper:readFile(filename))
end

return Helper

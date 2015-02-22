local Pool = class('Pool')

function Pool:initialize(params)
  self.contents = {}
  self:assignArgs(params.args)
end

function Pool:assignArgs(args)
end

return Pool
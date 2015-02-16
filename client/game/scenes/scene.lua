local Scene = class('Scene')

function Scene:initialize(json, module)
  -- JSON is used to define the layer instances (overlays,
  -- inputs, etc.) that will be used in this scene.
  self.json = Helper:readJSON(json)
  self.name = self.json._meta.name
  self.activeComp = self.json._meta.startingComp

  -- Logic is assigned to a Lua module that will be used for
  -- the scene's behavior.
  self.logic = (require(module)):new(self)
  self:addComponents()
end

-- Prepare everything we need for a scene.
function Scene:addComponents()
  -- Create a table to store layer groups
  self.layers = {
    animatedOverlays = {},
    grids = {},
    inputs = {},
    overlays = {}
  }

  -- Store transitions
  self.currentTransition = nil
  self.transitions = self.json.transitions

  -- Initialize the scene
  self:assignFromJSON('overlays')
  self:assignFromJSON('animatedOverlays')
  self:assignFromJSON('inputs')
  self:assignGrids()
end

-- Given a layer and a state, apply that layer's state as it
-- is defined in JSON to the layer instance.
function Scene:applyState(layer, state)
  for key, value in pairs(layer.states[state]) do
    layer.instance[key] = value
  end
end

-- Given a transition name, set that transition as the
-- active transition.
function Scene:applyTransition(name)
  self.currentTransition = self.transitions[name]
end

-- Given a key, JSON node and layer group, assign a new layer
-- to that layer group by the key, using the JSON node to
-- create the layer instance.
function Scene:assign(key, node, layerGroup)
  self.layers[layerGroup][key] = {}
  self.layers[layerGroup][key].defaultState = node.defaultState
  self.layers[layerGroup][key].states = node.states
  self.layers[layerGroup][key].instance = self:newLayer(node, layerGroup)
  self:applyState(self.layers[layerGroup][key], node.defaultState)
end

-- Given a layer group, iterate over the associated JSON,
-- assigning a new instance for each node.
function Scene:assignFromJSON(layerGroup)
  if self.json[layerGroup] then
    for key, value in pairs(self.json[layerGroup]) do
      self:assign(key, value, layerGroup)
    end
  end
end

-- Create new Grid instances.
function Scene:assignGrids()
  if self.json["grids"] then
    for key, grid in pairs(self.json["grids"]) do
      self.layers.grids[key] = {
        instance = Grid:new(grid.height, grid.width, grid.space_x, grid.space_y)
      }
    end
  end
end

-- Redirect an event from a child input.
function Scene:captureInputEvent(event, instance)
  local group = {}
  for key, input in pairs(self.layers.inputs) do
    if input.instance.groupName == instance.groupName then
      group[key] = input.instance
    end
  end
  self.logic:captureInputEvent(event, group)
end

-- Given a JSON node and layer group, create a new layer within
-- that layer group.
function Scene:newLayer(value, layerGroup)
  if layerGroup == 'overlays' then
    return Overlay:new(
      value.src,
      value.states[value.defaultState].x,
      value.states[value.defaultState].y
    )
  elseif layerGroup == 'animatedOverlays' then
    return AnimatedOverlay:new(
      value.src,
      value.states[value.defaultState].x,
      value.states[value.defaultState].y
    )
  elseif layerGroup == 'inputs' then
    return Input:new(
      self,
      'assets/gumps/input.png',
      value.states[value.defaultState].x,
      value.states[value.defaultState].y,
      TextOverlay:new(
        value.states[value.defaultState].text,
        value.states[value.defaultState].textX,
        value.states[value.defaultState].textY,
        value.states[value.defaultState].mask
      ),
      value.states[value.defaultState].submitEvent
    )
  end
end

-- Draw each layer instance and call the logic instance's tick
-- event.
function Scene:tick()
  for index, value in ipairs(self.json._comps[self.activeComp]) do
    if value[1] and value[2] then self.layers[value[1]][value[2]].instance:draw() end
    self.logic:tick()

    if self.currentTransition then self:transition() end
  end
end

-- Apply the current transition, removing it once the all instances
-- have been tweened.
function Scene:transition()
  for index, value in ipairs(self.currentTransition) do
    local layer = self.layers[value[1]][value[2]]
    if self:tweenAttributes(layer.instance, layer.states[value[3]], value[4]) then
      table.remove(self.currentTransition, index)
    end
  end

  if #self.currentTransition == 0 then
    self.currentTransition = nil
  end
end

-- Given a layer instance, a state to tween to and an increment
-- amount, add or subtract the amount to each state attribute
-- on the instance until it reaches the state attribute. Non
-- numerical state attributes will be applied immediately.
function Scene:tweenAttributes(instance, state, amount)
  for key, value in pairs(state) do
    local instanceAttribute = instance[key]
    if type(value) == "number" then
      if instanceAttribute < value then
        if instanceAttribute + amount > value then
          instance[key] = value
          return true
        else
          instance[key] = instanceAttribute + amount
        end
      elseif instanceAttribute >= value then
        if instanceAttribute - amount < value then
          instance[key] = value
          return true
        else
          instance[key] = instanceAttribute - amount
        end
      end
    else
      instance[key] = value
      return true
    end
  end
end

return Scene
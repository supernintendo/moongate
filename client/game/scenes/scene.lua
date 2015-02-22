local Scene = class('Scene')

function Scene:initialize(filePrefix)
  -- JSON is used to define the layer instances (overlays,
  -- inputs, etc.) that will be used in this scene.
  local json = 'game/scenes/json/'.. filePrefix .. '.json'
  local logic = 'game.scenes.logic.' .. filePrefix
  self.attr = Helper:readJSON(json)

  -- Logic is assigned to a Lua module that will be used for
  -- the scene's behavior.
  self.logic = (require(logic)):new(self)

  -- Storage and state
  self.contents = {}
  self.activeComp = "_Default"
  self.activeTransition = nil

-- Prepare everything we need for a scene.
  self:addComponents()
end

-- Add all components.
function Scene:addComponents()
  -- Initialize the scene
  for key, node in pairs(self.attr) do
    if self:isComponent(key) then
      self:assignFromNode(key, node)
    end
  end
end

-- Given a component and a state, apply that component's state
-- as it is defined in JSON to the component instance.
function Scene:applyState(component, state)
  for key, value in pairs(component.states[state]) do
    component.instance[key] = value
  end
  component.activeState = state
end

-- Given a transition name, set that transition as the
-- active transition.
function Scene:applyTransition(name)
  self.activeTransition = self.attr._Transitions[name]
end

-- Create the component and apply its default state.
function Scene:assignFromNode(key, node)
  self.contents[key] = {
    instance = _G[node._Class]:new(unpack(self:prepareArgs(node._Params))),
    states = node._States
  }
  self:applyState(self.contents[key], "_Default")
end

-- Redirect an event from a child input.
function Scene:captureEvent(event, child)
  local form = {}
  for key, component in pairs(self.contents) do
    if component.instance.submitEvent == child.submitEvent then
      form[key] = component.instance
    end
  end
  self.logic[event](self.logic, form)
end

-- Check if the JSON node represents a component in the scene.
function Scene:isComponent(key)
  return key ~= "_Meta" and
          key ~= "_Comps" and
          key ~= "_Transitions"
end

-- Given arguments from scene JSON, substitute special arguments.
function Scene:prepareArgs(args)
  prepared = {}

  for i, arg in ipairs(args) do
    if arg == "::parent" then table.insert(prepared, self)
    else table.insert(prepared, arg) end
  end

  return prepared
end

-- Draw each layer instance and call the logic instance's tick
-- event.
function Scene:tick()
  for i, componentName in ipairs(self.attr._Comps[self.activeComp]) do
    if self.contents[componentName] then
      self.contents[componentName].instance:draw()
    end

    self.logic:tick()

    if self.activeTransition then self:transition() end
  end
end

-- Apply the current transition, removing it once the all instances
-- have been tweened.
function Scene:transition()
  for i, value in ipairs(self.activeTransition) do
    local component = self.contents[value[1]]

    if self:tween(component.instance, component.states[value[2]], value[3]) then
      table.remove(self.activeTransition, index)
    end
  end

  -- Stop when all transitions are completed and removed from the table.
  if #self.activeTransition == 0 then self.activeTransition = nil end
end

-- Given a layer instance, a state to tween to and an increment
-- amount, add or subtract the amount to each state attribute
-- on the instance until it reaches the state attribute. Non
-- numerical state attributes will be applied immediately.
function Scene:tween(instance, state, amount)
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
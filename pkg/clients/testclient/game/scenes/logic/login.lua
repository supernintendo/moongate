local Login = class('Login')

function Login:initialize(parent)
  self.parent = parent
  self.state = {
    done = false,
    logInRequested = false,
    loggedIn = false,
    started = false,
    world = nil,
    worldPicked = false,
    worldsRequested = false
  }
end

function Login:captureInputEvent(event, group)
  if event == 'login' and (not self.state.logInRequested or self.state.loggedIn) then
    self:attemptLogin(group.username, group.password)
  end
end

function Login:attemptLogin(username, password)
  self.state.logInRequested = true
  TCP:send(
    'auth login '
    .. username.textOverlay.value
    .. ' ' .. password.textOverlay.value
  )
end

function Login:joinWorld()
  TCP:send('world join ' .. self.state.world)
  self.state.worldPicked = true
end

function Login:markAsLoggedIn()
  self.parent:applyTransition('loggedIn')
  self.parent.activeComp = 'loggedIn'
  self.state.loggedIn = true
end

function Login:tick()
  if not self.started then self:startIfNotStarted() end
  if authToken ~= 'anon' and not self.state.loggedIn then self:markAsLoggedIn() end
  if self.state.loggedIn and not self.state.worldsRequested then self:requestWorlds() end
  if self.state.worldsRequested and not self.state.worldPicked then self:pickWorld() end
  if self.state.world and not self.state.worldPicked then self:joinWorld() end
end

function Login:startIfNotStarted()
  self.parent:applyTransition('fadeIn')
  self.started = true
end

function Login:requestWorlds()
  TCP:send('worlds get')
  self.state.worldsRequested = true
end

function Login:pickWorld()
  for key, value in pairs(Worlds.worlds) do
    if not self.state.world then
      self.state.world = value.id
      currentScene = 'game'
    end
  end
end

return Login
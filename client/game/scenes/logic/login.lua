local Login = class('Login')

function Login:initialize(parent)
  self.parent = parent
  self.state = {
    done = false,
    logInRequested = false,
    loggedIn = false,
    started = false,
    worldPicked = false,
    worldsRequested = false
  }
end

function Login:login(form)
  self.state.logInRequested = true
  TCP:send(
    'auth login '
    .. form.inputUsername.textOverlay.value
    .. ' ' .. form.inputPassword.textOverlay.value
  )
end

function Login:joinWorld()
  TCP:send('world join ' .. currentWorld)
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
  if currentWorld and not self.state.worldPicked then self:joinWorld() end
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
      currentWorld = value.id
      currentScene = 'game'
    end
  end
end

return Login
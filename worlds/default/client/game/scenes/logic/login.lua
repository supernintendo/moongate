local Login = class('Login')

function Login:initialize(parent)
  self.parent = parent
  self.state = {
    done = false,
    logInRequested = false,
    loggedIn = false,
    started = false,
    sessionPicked = false,
    sessionsRequested = false
  }
end

function Login:login(form)
  self.state.logInRequested = true
  Network:send(
    'auth login '
    .. form.inputUsername.textOverlay.value
    .. ' ' .. form.inputPassword.textOverlay.value
  )
end

function Login:joinSession()
  Network:send('session join ' .. currentSession)
  self.state.sessionPicked = true
  currentScene = 'game'
end

function Login:markAsLoggedIn()
  self.parent:applyTransition('loggedIn')
  self.parent.activeComp = 'loggedIn'
  self.state.loggedIn = true
end

function Login:tick()
  if not self.started then self:startIfNotStarted() end
  if authToken ~= 'anon' and not self.state.loggedIn then self:markAsLoggedIn() end
  if self.state.loggedIn and not self.state.sessionsRequested then self:requestSessions() end
  if self.state.sessionsRequested and not self.state.sessionPicked then self:pickSession() end
  if currentSession and not self.state.sessionPicked and self.parent:get("space", "alpha") == 0 then
      self:joinSession()
  end
end

function Login:startIfNotStarted()
  self.parent:applyTransition('fadeIn')
  self.started = true
end

function Login:requestSessions()
  Network:send('sessions get')
  self.state.sessionsRequested = true
end

function Login:pickSession()
  for key, value in pairs(Sessions.sessions) do
    if not self.state.session then
      currentSession = value.id
    end
  end
end

return Login
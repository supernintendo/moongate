local Login = class('login')

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

function Login:captureInputEvent(event, group)
  if event == 'login' and (not self.state.logInRequested or self.state.loggedIn) then
    self:attemptLogin(group.username, group.password)
  end
end

function Login:attemptLogin(username, password)
  self.state.logInRequested = true
  TCP:send('auth login '
    .. username.textOverlay.value
    .. ' ' .. password.textOverlay.value)
end

function Login:markAsLoggedIn()
  self.parent:applyTransition('loggedIn')
  self.parent.activeComp = 'loggedIn'
  self.state.loggedIn = true
end

function Login:tick()
  if not self.started then self:startIfNotStarted() end
  if authToken ~= 'anon' and not self.state.loggedIn then self:markAsLoggedIn() end
end

function Login:startIfNotStarted()
  self.parent:applyTransition('fadeIn')
  self.started = true
end

return Login
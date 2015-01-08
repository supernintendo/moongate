local loginScreen = class('LoginScreen')
local MouseRange = require 'game.ui.listener.mouserange'

function loginScreen:initialize()
  self:defineAssets()
  self:applyInitialAssetState()
  self.started = true
  self.loggedIn = false
  self.askedForServerList = false
  self.hasServerList = false
  self.worldPicked = false
  self.done = false
end

function loginScreen:applyInitialAssetState()
  self.moon.alpha = 0
  self.space.alpha = 0 
  self.whoa.alpha = 0
  self.whoa.scaleX = 3
  self.whoa.scaleY = 3
  self.whoa.up = true  
end

function loginScreen:defineAssets()
  self.space = Overlay:new('assets/space.png', 0, 0)
  self.inputUsername = Input:new(
    'assets/input.png',
    DIMENSIONS.w / 2 - 130,
    DIMENSIONS.h - 160,
    TextOverlay:new(
      'Username',
      DIMENSIONS.w / 2 - 120,
      DIMENSIONS.h - 152,
      false
    )
  )
  self.inputPassword = Input:new(
    'assets/input.png',
    DIMENSIONS.w / 2 - 130,
    DIMENSIONS.h - 120,
    TextOverlay:new(
      'Password',
      DIMENSIONS.w / 2 - 120,
      DIMENSIONS.h - 112,
      true
    )
  )
  self.moon = AnimatedOverlay:new('assets/moon.json', DIMENSIONS.w / 2 - 50, 100)
  self.whoa = AnimatedOverlay:new('assets/whoa.json', 0, 0)
end

function loginScreen:draw()
  self.space:draw()
  self.inputUsername:draw()
  self.inputPassword:draw()
  self.moon:draw()
  self.whoa:draw()

  if authToken == "anon" then
    self:drawPreLogin()
  else
    self:drawPostLogin()

    if Worlds.worldsFetched then
      self:drawWorldList()      
    end
  end
end

function loginScreen:drawPreLogin()
  if self.moon.alpha < 120 then self.moon.alpha = self.moon.alpha + 0.2 end
  if self.space.alpha < 50 then self.space.alpha = self.space.alpha + 0.4 end
  if self.whoa.alpha < 5 then self.whoa.alpha = self.whoa.alpha + 0.05 end

  if self.whoa.up and self.whoa.y > -5 then self.whoa.y = self.whoa.y - 0.01 end
  if self.whoa.up and self.whoa.y <= -5 then self.whoa.up = false end
  if not self.whoa.up and self.whoa.y < 0 then self.whoa.y = self.whoa.y + 0.01 end
  if not self.whoa.up and self.whoa.y >= 0 then self.whoa.up = true end
  self.whoa.animation.interval = self.whoa.alpha / 20

  if self.inputUsername.submit or self.inputPassword.submit then
    self.inputUsername.submit = false
    self.inputPassword.submit = false
    TCP:send('auth login '
            .. self.inputUsername.textOverlay.value
            .. ' ' .. self.inputPassword.textOverlay.value)
  end
end

function loginScreen:drawPostLogin()
  self.inputUsername.disabled = true
  self.inputPassword.disabled = true

  if self.inputUsername.alpha > 0 then
    if self.inputUsername.alpha - 15 < 0 then self.inputUsername.alpha = 0
    else self.inputUsername.alpha = self.inputUsername.alpha - 15 end
  end

  if self.inputPassword.alpha > 0 then
    if self.inputPassword.alpha - 15 < 0 then self.inputPassword.alpha = 0
    else self.inputPassword.alpha = self.inputPassword.alpha - 15 end
  end

  if self.moon.alpha > 0 then
    if self.moon.alpha - 1.6 < 0 then self.moon.alpha = 0
    else self.moon.alpha = self.moon.alpha - 1.6 end
  end

  if not self.askedForServerList then
    TCP:send('worlds get')
    self.askedForServerList = true
  end
end

function loginScreen:drawWorldList()
  selected = false

  if not self.worldPicked then
    for index, world in pairs(Worlds["worlds"]) do
      if not selected then
        TCP:send('world join ' .. world["id"])
        currentWorld = world["id"]
      end

      selected = true
    end
    self.worldPicked = true
  end

  if currentWorld then
    self:deconstruct()
    self.done = true
  end
end

function loginScreen:deconstruct()
  local fadeAmount = 5

  if self.moon.alpha > 0 then
    if self.moon.alpha - fadeAmount >= 0 then
      self.moon.alpha = self.moon.alpha - fadeAmount
    else
      self.moon.alpha = 0
    end
  end

  if self.space.alpha > 0 then
    if self.space.alpha - fadeAmount >= 0 then
      self.space.alpha = self.space.alpha - fadeAmount
    else
      self.space.alpha = 0
    end
  end

  if self.whoa.alpha > 0 then
    if self.whoa.alpha - fadeAmount >= 0 then
      self.whoa.alpha = self.whoa.alpha - fadeAmount
    else
      self.whoa.alpha = 0
    end
  end
end

return loginScreen

-- Singleton modules
Helper = (require 'game.helper'):new()
KeyState = (require 'game.input.keys'):new()
MouseState = (require 'game.input.mouse'):new()
NetworkEvents = (require 'game.network.events'):new()

if PROTOCOL == 'TCP' then
  Network = (require 'game.network.tcp'):new()
elseif PROTOCOL == 'UDP' then
  Network = (require 'game.network.udp'):new()
end

Auth = (require 'game.network.auth'):new()
Sessions = (require 'game.network.sessions'):new()

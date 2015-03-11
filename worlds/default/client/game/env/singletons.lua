-- Singleton modules
Helper = (require 'game.helper'):new()
KeyState = (require 'game.input.keys'):new()
MouseState = (require 'game.input.mouse'):new()
NetworkEvents = (require 'game.network.events'):new()
TCP = (require 'game.network.tcp'):new()
Auth = (require 'game.network.auth'):new()
Sessions = (require 'game.network.sessions'):new()

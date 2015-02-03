-- External dependencies
inspect = require 'lib.inspect'
JSON = require 'lib.JSON'
class = require 'lib.middleclass'
socket = require 'socket'

-- Singleton modules
Helper = (require 'game.helper'):new()
KeyState = (require 'game.input.keys'):new()
MouseState = (require 'game.input.mouse'):new()
NetworkEvents = (require 'game.network.events'):new()
TCP = (require 'game.network.tcp'):new()
Auth = (require 'game.network.auth'):new()
Worlds = (require 'game.network.worlds'):new()

-- Global classes
Overlay = require 'game.ui.overlay.basic'
Animation = require 'game.utility.animation'
AnimatedOverlay = require 'game.ui.overlay.animated'
TextOverlay = require 'game.ui.overlay.text'
Input = require 'game.ui.menu.input'
Scene = require 'game.scenes.scene'

-- Environmental globals
authToken = 'anon'

-- External dependencies
inspect = require 'deps.inspect.inspect'
JSON = require 'deps.dkjson.dkjson'
class = require 'deps.middleclass.middleclass'
socket = require 'socket'

-- Singleton modules
Helper = (require 'game.helper'):new()
KeyState = (require 'game.input.keys'):new()
MouseState = (require 'game.input.mouse'):new()
NetworkEvents = (require 'game.network.events'):new()
TCP = (require 'game.network.tcp'):new()
Auth = (require 'game.network.auth'):new()
GridState = (require 'game.network.grid'):new()
Worlds = (require 'game.network.worlds'):new()

-- Global classes
Overlay = require 'game.ui.overlay.basic'
Animation = require 'game.utility.animation'
AnimatedOverlay = require 'game.ui.overlay.animated'
TextOverlay = require 'game.ui.overlay.text'
Input = require 'game.ui.menu.input'
Grid = require 'game.game.grid'
Tile = require 'game.game.tile'
Entity = require 'game.game.entity'
Scene = require 'game.scenes.scene'
pub = {
  entities = (require 'game.network.entities'):new()
}

-- Environmental globals
authToken = 'anon'
currentScene = 'login'
currentWorld = nil
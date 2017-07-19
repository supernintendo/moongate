(function() {
  var Game = {
    mouseDown: false,
    players: {},
    playerEls: {},
    pos: {
      x: 0,
      y: 0
    },
    addPlayer: function(player) {
      var index = player.__index__;

      Game.players[index] = player;
      Game.playerEls[index] = document.createElement("LI");
      Client.tether(player, this.players[index]);

      document.getElementById('board').appendChild(Game.playerEls[index]);
    },
    allPlayers: function() {
      var results = document.querySelectorAll('ul#board li');

      return results;
    },
    dropPlayers: function(payload) {
      payload.indices.forEach(function(i) {
        Game.removePlayer(i);
      }.bind(this));
    },
    getPlayerEl: function(i) {
      return Game.playerEls[i];
    },
    movePlayer: function(e) {
      if (Game.mouseDown) {
        Client.send('move', {
          body: [
            ((e.clientX - 24) / window.innerWidth),
            ((e.clientY - 24) / window.innerHeight)
          ]
        });
      }
    },
    refresh: function(players) {
      players.forEach(function(player) {
        var index = player.__index__;

        if (Client.meta(player, 'isNew')) {
          Game.addPlayer(player);
        };
        Game.refreshPlayerPosition(Game.getPlayerEl(index), Game.players[index]);
      });
    },
    removePlayer: function(i) {
      var playerEl = Game.getPlayerEl(i);

      playerEl && playerEl.parentNode.removeChild(playerEl);
    },
    refreshPlayerPosition(el, player) {
      el.style.transform =
        'translateX(' +
        ((player.x * window.innerWidth)) +
        'px) translateY(' +
        ((player.y * window.innerHeight)) +
        'px)';
      el.style.transitionDuration = player.speed + 'ms';
    },
    tick() {
      Client.processBatch();
      requestAnimationFrame(Game.tick.bind(Game));
    }
  },
  Client = new Moongate.Client({
    callbacks: {
      dropMembers: function(payload) {
        Game.dropPlayers(payload);
      },
      indexMembers: function(players) {
        Game.refresh(players || []);
      },
      showMembers: function(players) {
        for (var i = 0, l = players.length; i !== l; i++) {
          var index = players[i].__index__;

          Game.refreshPlayerPosition(Game.getPlayerEl(index), Game.players[index]);
        }
      }
    },
    directives: {
      move: {
        handler: 'call',
        rule: 'Movement',
        ring: 'Player',
        zone: 'Level'
      }
    }
  });
  document.onmousemove = Game.movePlayer.bind(Game);
  document.onmousedown = function(e) {
    Game.mouseDown = true;
    Game.movePlayer(e);
  }
  document.onmouseup = function() {
    Game.mouseDown = false;
  }
  window.onresize = function() {
    Client.utils.loop(function(el) {
      Game.refreshPlayerPosition(el);
    }, Game.allPlayers());
  }
  Game.tick();
})();

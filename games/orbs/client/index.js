(function() {
  var Board = {},
      Game = {
        addEntity: function(ring, member) {
          var el = document.createElement("DIV");
          el.className = ring;
          el.dataset.ring = ring;
          el.dataset.index = member.index();
          el.dataset.x = member.attributes.x;
          el.dataset.y = member.attributes.y;
          document.getElementById('board').appendChild(el);
        },
        applyBindings: function() {
          document.onclick = function(e) {
            Client.send({
              body: [e.clientX - 24, e.clientY - 24],
              handler: 'call',
              rule: 'Movement',
              ring: 'Player',
              zone: ['Level', 'lobby']
            });
          }
        },
        dropEntities: function(params) {
          return params.indices.map((index) => {
            let entity = Game.getEntity(params.ring, index);

            if (entity) {
              entity.parentNode.removeChild(entity);
              return true;
            }
            return false;
          });
        },
        getEntity: function(key, index) {
          var results = document.querySelectorAll(
            '[data-ring="' + key +
            '"][data-index="' + index + '"]'
          );
          return results[0];
        },
        getAllEntities: function() {
          var results = document.querySelectorAll('[data-ring]');

          return results;
        },
        updateEntity: function(entity, member) {
          entity.dataset.x = member.attributes.x;
          entity.dataset.y = member.attributes.y;
        },
        refreshBoard: function() {
          var entities = Game.getAllEntities(),
              l = entities.length,
              entities;

          while (l--) {
            entity = entities[l];
            entity.style.transform = (
              "translateX(" + entity.dataset.x +
              "px) translateY(" + entity.dataset.y + "px)"
            );
          }
        },
        updateEntities: function(members) {
          members.forEach(function(member) {
            var ring = member._.name,
                entity = Game.getEntity(ring, member.index());

            if (entity) {
              Game.updateEntity(entity, member);
            } else {
              Game.addEntity(ring, member);
            }
            Game.refreshBoard();
          });
        }
      },
      Client = new Moongate.Client({
        callbacks: {
          dropMembers: function(params) {
            Game.dropEntities(params);
          },
          indexMembers: function(members) {
            Game.updateEntities(members || []);
          },
          showMembers: function(members) {
            Game.updateEntities(members || []);
          }
        },
        directives: {},
        onConnect: function() {
          Game.applyBindings();
        }
      });
})();

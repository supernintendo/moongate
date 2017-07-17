(function() {
  var Game = {
    updateLog: function(message) {
      var logEl = document.getElementById('log'),
          li = document.createElement("LI"),
          text = document.createTextNode(message);

      li.appendChild(text);
      logEl.appendChild(li);
    }
  },
  Client = new Moongate.Client({
    callbacks: {
      echo: function(message) {
        Game.updateLog(message);
      },
      statusChange: function(code) {
        if (Client.status(code) === 'connected') {
          var formEl = document.getElementById('chat'),
              input = formEl.querySelector('input');

          formEl.onsubmit = function(e) {
            Client.send({
              body: [input.value],
              handler: 'post_message',
              zone: 'Lobby'
            });
            input.value = '';
            e.preventDefault();
          };
        }
      }
    },
    directives: {},
  });
})();

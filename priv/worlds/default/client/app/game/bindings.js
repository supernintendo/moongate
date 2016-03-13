let GamePackets = require('./game-packets');

let Bindings = {
    authenticated() {
        this.send('proceed');
    },
    keydown(e, key, first) {
        if (first) {
            let packet = GamePackets.keydown(key);

            if (packet) {
                this.send.apply(this, packet);
                return true;
            }
        }
    },
    keyup(e, key) {
        if (this.keysNotPressed(87, 65, 83, 68)) {
            this.send('Player.Movement', 'stop', 1, 1);
        } else {
            this.send.apply(this, GamePackets.keyup(key, this));
        }
    },
    tick(game) {
        game.canvas.tick();
    }
};

export default Bindings;

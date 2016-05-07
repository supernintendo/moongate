let GamePackets = require('./game-packets');

let Bindings = {
    pool: {
        create(member) {
        }
    },
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
            this.send('Player.Movement', 'move', 'xreset', 'yreset');
        } else {
            this.send.apply(this, GamePackets.keyup(key, this));
        }
    },
    tick(game) {
    }
};
export default Bindings;

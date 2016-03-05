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
        if (this.keysAreNotDown(87, 65, 83, 68)) {
            this.send('Player.Movement', 'stop', 1, 1);
        } else {
            this.send.apply(this, GamePackets.keyup(key, this));
        }
    },
    poolCreate(member, key, pool) {
        let parts = pool.split('_'),
            layer = parts[parts.length - 1];

        this.game.canvas.addToLayer(layer, member, key);
    },
    poolUpdate(member, key, pool) {
        let parts = pool.split('_'),
            layer = parts[parts.length - 1];

        this.game.canvas.syncInLayer(layer, member, key);
    },
    tick(game) {
        game.canvas.tick();
    }
};

export default Bindings;

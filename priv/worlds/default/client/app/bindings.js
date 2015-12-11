let GamePackets = require('./game-packets');

let Bindings = {
    authenticated() {
        this.stageSend('proceed');
    },
    keydown(e, key, first) {
        if (first) {
            let packet = GamePackets.keydown(key);

            if (packet) {
                this.stageSend(packet);
                return true;
            }
        }
    },
    keyup(e, key) {
        if (this.keysAreNotDown(87, 65, 83, 68)) {
            this.stageSend('stop 1 1');
        } else {
            this.stageSend(GamePackets.keyup(key, this));
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

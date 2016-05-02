let GamePackets = require('./game-packets'),
    Board = require('./board');

let Bindings = {
    pool: {
        create(member) {
            Board.add(member);
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
        Board.update();
        // game.gate
        //     .stage('testLevel')
        //     .pool('player')
        //     .all()
        //     .forEach((player) => {});
    }
};
export default Bindings;

let Bindings = require('./game/bindings'),
    Moongate = require('moongate');

class Game {
    constructor() {
        this.gate = new Moongate(Bindings, {
            game: this,
            logs: {
                all: true
            }
        });
    }
    start() {
        this.gate.connect('127.0.0.1', 2593, this.login.bind(this));
        this.gate.tick(this);
    }
    login() {
        this.gate.login('test', 'moongate');
    }
}
export default Game;

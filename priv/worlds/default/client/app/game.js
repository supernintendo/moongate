let Bindings = require('./game/bindings'),
    Board = require('./game/board'),
    Moongate = require('moongate');

class Game {
    constructor() {
        this.board = new Board('#board');
        this.gate = new Moongate(Bindings, {
            game: this,
            logs: {
                all: true
            }
        });
        this.state = {
            mouseTimer: 0
        };
    }
    start() {
        console.log(this);
        this.gate.connect('127.0.0.1', 2593, this.login.bind(this));
        this.gate.tick(this);

        // Send mouse position
        $(window).on('mousemove', (e) => {
            if (this.gate.connected && this.state.mouseTimer <= 0) {
                this.gate.send('Player.Movement', 'move', e.pageX, e.pageY);
                this.state.mouseTimer = 1;
            }
        });
    }
    login() {
        this.gate.login('test', 'moongate');
    }
}
export default Game;

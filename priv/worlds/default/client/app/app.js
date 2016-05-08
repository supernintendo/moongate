let Bindings = require('./src/bindings'),
    Board = require('./src/board'),
    Moongate = require('moongate');

class App {
    constructor() {
        this.board = new Board('#board');
        this.gate = new Moongate(Bindings, {
            app: this,
            logs: {
                all: true
            }
        });
        this.state = {
            mouseTimer: 0
        };
    }
    start() {
        console.log(this.gate);
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
export default App;

let Assets = require('./game/assets'),
    Canvas = require('./game/canvas'),
    Events = require('./game/events'),
    Bindings = require('./game/bindings'),
    Moongate = require('moongate');

class Game extends Events {
    constructor() {
        super();
        this.assets = new Assets('data/assets.json');
        this.gate = new Moongate(Bindings, {
            game: this,
            logs: {
                all: true
            }
        });
        this.listenTo(this.assets, 'loaded', this.startGame);
        this.assets.load();
    }
    startGame() {
        this.canvas = new Canvas({
            assets: this.assets
        });
        this.gate.connect('127.0.0.1', 2593, this.login.bind(this));
        this.gate.tick(true, [this]);
        console.log(this.gate);
    }
    login() {
        this.gate.login('test', 'moongate');
    }
}
export default Game;

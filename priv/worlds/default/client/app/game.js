let Assets = require('./assets'),
    Canvas = require('./canvas'),
    Events = require('./events'),
    Bindings = require('./bindings'),
    Moongate = require('moongate');

class Game extends Events {
    constructor() {
        super();
        this.assets = new Assets('data/assets.json');
        this.gate = new Moongate(Bindings, {
            game: this
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
    }
    login() {
        this.gate.login('foo', 'bar');
    }
}
export default Game;

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
            mouseTimer: 0,
            lastMouseX: 0,
            lastMouseY: 0
        };
    }
    bindMouse() {
        // // Send mouse position
        $(window).on('mousemove', (e) => {
            if (this.gate.connected && this.state.mouseTimer <= 0) {
                this.mouseMoved();
                this.state.mouseTimer = 15;
            }
            this.state.lastMouseX = e.pageX;
            this.state.lastMouseY = e.pageY;
        });
    }
    login() {
        this.gate.login(this.name(), 'moongate');
    }
    mouseMoved() {
        this.gate.send(
            'Player.Movement',
            'move',
            this.state.lastMouseX,
            this.state.lastMouseY
        );
    }
    name() {
        let adjectives = [
            'aloof',
            'annoyed',
            'anxious',
            'aquatic',
            'breezy',
            'careful',
            'confused',
            'disillusioned',
            'fantastic',
            'fine',
            'fluffy',
            'fresh',
            'friendly',
            'gaudy',
            'giddy',
            'grouchy',
            'happy',
            'itchy',
            'knowledgeable',
            'lazy',
            'loving',
            'marvelous',
            'pastoral',
            'sleepy',
            'spicy',
            'supreme',
            'tart',
            'teeny-tiny',
            'unusual',
            'weird'
        ];
        let animals = [
            'ape',
            'basilisk',
            'blue-crab',
            'capybara',
            'chicken',
            'cougar',
            'deer',
            'fish',
            'fox',
            'frog',
            'hamster',
            'gazelle',
            'gopher',
            'grizzly-bear',
            'kitten',
            'koala',
            'lizard',
            'mule',
            'newt',
            'otter',
            'ox',
            'panda',
            'puppy',
            'rabbit',
            'seal',
            'squirrel',
            'tiger',
            'walrus',
            'weasel',
            'wombat'
        ];
        let adjective = adjectives[Math.floor(Math.random() * [adjectives.length - 1])],
            animal = animals[Math.floor(Math.random() * [animals.length - 1])];

        return `${adjective}-${animal}`;
    }
    start() {
        $.ajax({
            url: '/moongate-manifest.json',
            success: (response) => {
                this.gate.connect(response.ip, 2593, this.login.bind(this));
                this.gate.tick(this);
                this.bindMouse();
            }
        });
    }
}
export default App;

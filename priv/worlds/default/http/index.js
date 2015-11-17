var GameGate = new Moongate(Game);

document.getElementById('canvas-container').appendChild(GameCanvas.renderer.view);

GameAssets.load(function() {
    GameGate.connect('127.0.0.1', 2593, function() {
        GameGate.login('foo', 'bar');
    });
    GameCanvas.init();
    GameGate.tick(true);
});

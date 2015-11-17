var GameGate = new Moongate(Game);

document.getElementById('canvas-container').appendChild(GameCanvas.renderer.view);

GameAssets.load(function() {
    GameGate.connect(window.location.hostname, 2593, function() {
        GameGate.login('foo', 'bar');
    });
    GameCanvas.init();
    GameGate.tick(true);
});

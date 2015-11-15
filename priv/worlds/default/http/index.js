var GameGate = new Moongate(Game);

document.body.appendChild(GameCanvas.renderer.view);
GameCanvas.loadAssets(function() {
    GameGate.connect('127.0.0.1', 2593, function() {
        GameGate.login('foo', 'bar');
    });
    GameGate.tick(true);
});

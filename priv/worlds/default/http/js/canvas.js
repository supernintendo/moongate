var GameCanvas = {
    stage: new PIXI.Container(),
    renderer: PIXI.autoDetectRenderer(640, 512),
    assets: {},
    entities: {},
    addEntity: function(key, member) {
        GameCanvas.entities[key] = {
            member: member,
            sprite: new PIXI.Sprite(GameCanvas.assets.player.texture)
        };
        GameCanvas.syncEntity(key);
        GameCanvas.stage.addChild(GameCanvas.entities[key].sprite);
    },
    loadAssets: function(callback) {
        PIXI.loader.add('player', 'sprites/player.png').load(function(loader, resources) {
            this.assets = resources;
            callback();
        }.bind(this));
    },
    syncAllEntities: function() {
        var i, k = Object.keys(this.entities);

        for (i = 0; i < k.length; i++) {
            this.syncEntity(k[i]);
        }
    },
    syncEntity: function(key) {
        this.entities[key].sprite.position.x = this.entities[key].member.get('x');
        this.entities[key].sprite.position.y = this.entities[key].member.get('y');
    },
    tick: function() {
        GameCanvas.syncAllEntities();
        GameCanvas.renderer.render(GameCanvas.stage);
    }
};

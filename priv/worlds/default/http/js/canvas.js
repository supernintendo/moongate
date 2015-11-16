var GameCanvas = {
    stage: new PIXI.Container(),
    renderer: PIXI.autoDetectRenderer(640, 512),
    assets: {},
    entities: {},
    addEntity: function(pool, key, member) {
        if (!GameCanvas.entities[pool]) {
            GameCanvas.entities[pool] = {};
        }
        GameCanvas.entities[pool][key] = {
            member: member,
            sprite: new PIXI.Sprite(GameCanvas.assets[pool].texture)
        };
        GameCanvas.syncEntity(pool, key);
        GameCanvas.stage.addChild(GameCanvas.entities[pool][key].sprite);
    },
    loadAssets: function(callback) {
        PIXI.loader
            .add('test_level_character', 'sprites/player.png')
            .add('test_level_projectile', 'sprites/projectile.png')
            .load(function(loader, resources) {
                this.assets = resources;
                callback();
            }.bind(this));
    },
    removeEntity: function(pool, key, member) {
        GameCanvas.stage.removeChild(GameCanvas.entities[pool][key].sprite);
        delete GameCanvas.entities[pool][key];
    },
    syncAllEntities: function(pool) {
        if (!this.entities[pool]) {
            return;
        }
        var i, k = Object.keys(this.entities[pool]);

        for (i = 0; i < k.length; i++) {
            this.syncEntity(pool, k[i]);
        }
    },
    syncEntity: function(pool, key) {
        this.entities[pool][key].sprite.position.x = this.entities[pool][key].member.get('x');
        this.entities[pool][key].sprite.position.y = this.entities[pool][key].member.get('y');
    },
    tick: function() {
        GameCanvas.syncAllEntities('test_level_character');
        GameCanvas.syncAllEntities('test_level_projectile');
        GameCanvas.renderer.render(GameCanvas.stage);
    }
};

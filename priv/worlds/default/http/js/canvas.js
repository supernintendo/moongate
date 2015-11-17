var GameCanvas = {
    stage: new PIXI.Container(),
    renderer: PIXI.autoDetectRenderer(640, 512),
    entities: {},
    characterContainer: new PIXI.Container(),
    itemContainer: new PIXI.Container(),
    grooveInterval: 0,
    groove: 60,
    refreshLayerInterval: 0,
    refreshLayerEvery: 15,
    projectileContainer: new PIXI.Container(),
    tileContainer: new PIXI.Container(),
    tints: [
        0x0532FD,
        0x5243CF,
        0xA7259D,
        0xBD1B35,
        0xFF5000,
        0xFEAF59,
        0x00C000,
        0x63F5AC
    ],
    addEntity: function(pool, key, member) {
        if (!GameCanvas.entities[pool]) {
            GameCanvas.entities[pool] = {};
        }
        GameCanvas.entities[pool][key] = {
            member: member,
            sprite: new PIXI.Sprite(),
            sprites: GameSprites.spritesFor(pool, member)
        };
        GameCanvas.syncEntity(pool, key);
        this.drawEntityToStage(pool, GameCanvas.entities[pool][key].sprite);
    },
    containerForPool: function(pool) {
        var parts = pool.split('_'),
            key = parts[parts.length - 1] + 'Container';

        return this[key];
    },
    drawEntityToStage: function(pool, sprite) {
        var container = this.containerForPool(pool);

        if (container) {
            container.addChild(sprite);
        }
    },
    init: function() {
        this.projectileContainer.zIndex = 1;
        this.characterContainer.zIndex = 2;
        this.itemContainer.zIndex = 3;
        this.tileContainer.zIndex = 4;

        this.stage.addChild(this.projectileContainer);
        this.stage.addChild(this.characterContainer);
        this.stage.addChild(this.itemContainer);
        this.stage.addChild(this.tileContainer);
        this.updateLayersOrder();
    },
    refreshLayersForPool: function(pool, key) {
        var container = this.containerForPool(pool),
            entities = this.entities[pool],
            k = Object.keys(entities);

        k.sort(function(a, b) {
            return entities[a].member.get(key) - entities[b].member.get(key);
        }).forEach(function(index) {
            container.removeChild(entities[index].sprite);
            container.addChild(entities[index].sprite);
        });
    },
    removeEntity: function(pool, key, member) {
        var container = this.containerForPool(pool);

        container.removeChild(GameCanvas.entities[pool][key].sprite);
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
        var entity = this.entities[pool][key],
            direction = entity.member.get('direction'),
            origin = entity.member.origin,
            stance = entity.member.get('stance'),
            index;

        entity.sprite.position.x = entity.member.get('x');
        entity.sprite.position.y = entity.member.get('y');

        if (origin.owned) {
            GameHUD.update({
                health: entity.member.get('health'),
                maxHealth: entity.member.get('max_health'),
                rupees: entity.member.get('rupees')
            });
        }
        if (direction) {
            if (stance === 0) {
                entity.sprite.texture = entity.sprites[direction][0];
            } else {
                index = Math.round((this.grooveInterval / this.groove) * 3);

                entity.sprite.texture = entity.sprites[direction][index];
            }
        }
    },
    tick: function() {
        this.grooveInterval++;
        this.refreshLayerInterval++;

        if (this.grooveInterval > this.groove) {
            this.grooveInterval = 0;
        }
        if (this.refreshLayerInterval > this.refreshLayerEvery) {
            this.refreshLayersForPool('test_level_character', 'y');
            this.refreshLayerInterval = 0;
        }
        GameCanvas.syncAllEntities('test_level_character');
        // GameCanvas.syncAllEntities('test_level_projectile');
        GameCanvas.renderer.render(GameCanvas.stage);
    },
    updateLayersOrder: function() {
        this.stage.children.sort(function(a, b) {
            a.zIndex = a.zIndex || 0;
            b.zIndex = b.zIndex || 0;
            return b.zIndex - a.zIndex;
        });
    }
};

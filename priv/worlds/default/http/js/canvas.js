var GameCanvas = {
    stage: new PIXI.Container(),
    renderer: PIXI.autoDetectRenderer(640, 512),
    entities: {},

    characterContainer: new PIXI.Container(),
    grooveInterval: 0,
    groove: 60,
    refreshLayerInterval: 0,
    refreshLayerEvery: 15,
    particleContainer: new PIXI.Container(),
    pickupContainer: new PIXI.Container(),
    projectileContainer: new PIXI.Container(),
    soundEffects: {
        dead: new Audio('sounds/dead.wav'),
        slash: new Audio('sounds/slash.wav')
    },
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
        this.handleNewEntity(pool, GameCanvas.entities[pool][key]);
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
    handleNewEntity(pool, entity) {
        var parts = pool.split('_'),
            direction;

        if (parts[parts.length - 1] === 'particle') {
            direction = entity.member.get('direction');
            this.playSoundEffectIfLoaded(entity.member.get('type'));
            entity.sprite.texture = entity.sprites[direction][0];
            entity.sprites[direction].forEach(function(sprite, index) {
                setTimeout(function() {
                    entity.sprite.texture = sprite;
                }, index * 100);
            }, this);
        }
    },
    init: function() {
        this.projectileContainer.zIndex = 1;
        this.characterContainer.zIndex = 2;
        this.particleContainer.zIndex = 2;
        this.pickupContainer.zIndex = 4;
        this.tileContainer.zIndex = 5;

        this.stage.addChild(this.projectileContainer);
        this.stage.addChild(this.characterContainer);
        this.stage.addChild(this.particleContainer);
        this.stage.addChild(this.pickupContainer);
        this.stage.addChild(this.tileContainer);
        this.updateLayersOrder();
    },
    playSoundEffectIfLoaded: function(sound) {
        if (this.soundEffects[sound]) {
            this.soundEffects[sound].play();
        }
    },
    refreshLayersForPool: function(pool, key) {
        var container = this.containerForPool(pool),
            entities = this.entities[pool],
            k;

        if (entities) {
            k = Object.keys(entities);

            k.sort(function(a, b) {
                return entities[a].member.get(key) - entities[b].member.get(key);
            }).forEach(function(index) {
                container.removeChild(entities[index].sprite);
                container.addChild(entities[index].sprite);
            });
        }
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
    syncCharacter: function(entity) {
        var direction = entity.member.get('direction'),
            health = entity.member.get('health'),
            origin = entity.member.origin,
            stance = entity.member.get('stance'),
            index;

        if (origin && origin.owned) {
            GameHUD.update({
                health: entity.member.get('health'),
                maxHealth: entity.member.get('max_health'),
                rupees: entity.member.get('rupees')
            });
        }
        if (health <= 0) {
            entity.sprite.texture = entity.sprites.dead[0];
        } else if (direction) {
            if (stance === 0) {
                entity.sprite.texture = entity.sprites[direction][0];
            } else {
                index = Math.round((this.grooveInterval / this.groove) * 3);

                entity.sprite.texture = entity.sprites[direction][index];
            }
        }
    },
    syncEntity: function(pool, key) {
        var entity = this.entities[pool][key];

        entity.sprite.position.x = entity.member.get('x');
        entity.sprite.position.y = entity.member.get('y');

        if (pool === 'test_level_character') {
            this.syncCharacter(entity);
        }
        if (pool === 'test_level_pickup') {
            this.syncPickup(entity);
        }
    },
    syncPickup: function(entity) {
        var index = Math.round((this.grooveInterval % this.groove) / this.groove * (entity.sprites.default.length - 1));
        entity.sprite.texture = entity.sprites.default[index];
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
        GameCanvas.syncAllEntities('test_level_pickup');
        GameCanvas.syncAllEntities('test_level_projectile');
        GameCanvas.syncAllEntities('test_level_particle');
        GameCanvas.renderer.render(GameCanvas.stage);

        if (document.getElementById('health').innerHTML === '0' && !this.redirecting) {
            this.playSoundEffectIfLoaded('dead');
            this.redirecting = true;
            window.location.href = window.location;
        }
    },
    updateLayersOrder: function() {
        this.stage.children.sort(function(a, b) {
            a.zIndex = a.zIndex || 0;
            b.zIndex = b.zIndex || 0;
            return b.zIndex - a.zIndex;
        });
    }
};

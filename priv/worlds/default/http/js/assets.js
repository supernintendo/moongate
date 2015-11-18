var GameAssets = {
    load: function(callback) {
        PIXI.loader
            .add('bone', 'sprites/bone.png')
            .add('dark-force', 'sprites/dark-force.png')
            .add('elf', 'sprites/elf.png')
            .add('fire', 'sprites/fire.png')
            .add('gem-blue', 'sprites/gem-blue.png')
            .add('gem-green', 'sprites/gem-green.png')
            .add('gem-red', 'sprites/gem-red.png')
            .add('jewel', 'sprites/jewel.png')
            .add('mage', 'sprites/mage.png')
            .add('meat', 'sprites/meat.png')
            .add('shields', 'sprites/shields.png')
            .add('skeleton', 'sprites/skeleton.png')
            .add('slash', 'sprites/slash.png')
            .add('sparkles', 'sprites/sparkles.png')
            .add('swords', 'sprites/swords.png')
            .add('tiles-castle', 'sprites/tiles-castle.png')
            .add('tiles-desert', 'sprites/tiles-desert.png')
            .add('tiles-forest', 'sprites/tiles-forest.png')
            .load(function(loader, resources) {
                var k = Object.keys(resources), l = k.length;

                while (l--) {
                    GameSprites.sheets[k[l]] = resources[k[l]].texture.baseTexture;
                }
                callback();
            }.bind(this));
    }
};

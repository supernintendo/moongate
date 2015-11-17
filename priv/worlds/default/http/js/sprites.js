GameSprites = {
    generateSpritesheet: function(sheet, sprites) {
        var k = Object.keys(sprites),
            l = k.length,
            result = {},
            sprite,
            x, y, h, w;

        while (l--) {
            result[k[l]] = sprites[k[l]].map(function(dimensions) {
                x = dimensions[0];
                y = dimensions[1];
                h = dimensions[2];
                w = dimensions[3];
                return new PIXI.Texture(sheet, new PIXI.Rectangle(x, y, h, w));
            });
        }
        return result;
    },
    sheets: {},
    spritesFor: function(pool, member) {
        var parts = pool.split('_'),
            poolName = parts[parts.length - 1];

        if (this[poolName]) {
            return this[poolName](member);
        }
        return null;
    },
    character: function(member) {
        var archetype = member.get('archetype');

        switch(archetype) {
        case 'elf':
            return this.generateSpritesheet(this.sheets.elf, {
                up: [
                    [5, 2, 30, 30],
                    [39, 2, 30, 30],
                    [76, 2, 30, 30],
                    [108, 2, 30, 30]
                ],
                left: [
                    [5, 37, 30, 30],
                    [39, 37, 30, 30],
                    [76, 37, 30, 30],
                    [108, 37, 30, 30]
                ],
                down: [
                    [5, 70, 30, 30],
                    [39, 70, 30, 30],
                    [76, 70, 30, 30],
                    [108, 70, 30, 30]
                ],
                right: [
                    [5, 103, 30, 30],
                    [39, 103, 30, 30],
                    [76, 103, 30, 30],
                    [108, 103, 30, 30]
                ]
            });
        case 'mage':
            return this.generateSpritesheet(this.sheets.mage, {
                up: [
                    [2, 74, 30, 34],
                    [34, 74, 30, 34],
                    [66, 74, 30, 34],
                    [34, 74, 30, 34]
                ],
                left: [
                    [2, 112, 30, 34],
                    [34, 112, 30, 34],
                    [66, 112, 30, 34],
                    [34, 112, 30, 34]
                ],
                down: [
                    [2, 2, 30, 34],
                    [34, 2, 30, 34],
                    [66, 2, 30, 34],
                    [34, 2, 30, 34]
                ],
                right: [
                    [2, 38, 30, 34],
                    [34, 38, 30, 34],
                    [66, 38, 30, 34],
                    [34, 38, 30, 34]
                ]
            });
        case 'skeleton':
            return this.generateSpritesheet(this.sheets.skeleton, {
                up: [
                    [2, 114, 30, 34],
                    [32, 114, 30, 34],
                    [64, 114, 30, 34],
                    [96, 114, 30, 34],
                ],
                left: [
                    [96, 4, 30, 34],
                    [2, 4, 30, 34],
                    [32, 4, 30, 34],
                    [64, 4, 30, 34]
                ],
                down: [
                    [2, 74, 30, 34],
                    [32, 74, 30, 34],
                    [64, 74, 30, 34],
                    [96, 74, 30, 34],
                ],
                right: [
                    [2, 40, 30, 34],
                    [30, 40, 30, 34],
                    [62, 40, 30, 34],
                    [94, 40, 30, 34],
                ]
            });
        default:
            return {};
        }
    }
};

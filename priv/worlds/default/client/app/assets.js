let Events = require('./events');

class Assets extends Events {
    constructor(source) {
        super();
        this.sprites = {};
        this.sounds = {};
        this.source = source;
    }
    ajax(url, type, callback) {
        $.ajax({
            url: url,
            contentType: this.contentTypeFor(type),
            success: callback
        });
    }
    constructSprite(part, image) {
        let k = Object.keys(part),
            l = k.length,
            result = {
                directions: {}
            };

        while (l--) {
            let key = k[l];

            if (key[0] === '_') {
                result[key.substring(1)] = part[key];
            } else {
                result.directions[key] = this.generateSprite(part[key], image);
            }
        }
        return result;
    }
    contentTypeFor(type) {
        switch (type) {
        case 'json':
            return 'application/json';
        default:
            return 'text/plain';
        }
    }
    generateSprite(offsets, image) {
        return offsets.map((offset) => {
            let texture = image.texture.baseTexture,
                x = offset[0],
                y = offset[1],
                w = offset[2],
                h = offset[3];

            return new PIXI.Texture(texture, new PIXI.Rectangle(x, y, w, h));
        });
    }
    load() {
        this.ajax(this.source, 'json', (response) => {
            let parsed = JSON.parse(response),
                loader = PIXI.loader;

            this.prepareSprites(loader, parsed.sprites);
            this.prepareSounds(loader, parsed.sounds);
            loader.load((loader, resources) => {
                this.useResources(resources, parsed);
            });
        });
    }
    prepareSounds(loader, sounds) {
        sounds.forEach((sound) => {
            if (!loader.resources[`sound-${sound}`]) {
                loader.add(`sound-${sound}`, `sounds/${sound}.wav`);
            }
        });
    }
    prepareSprites(loader, sprites) {
        let k = Object.keys(sprites),
            l = k.length;

        while (l--) {
            let key = k[l],
                image = sprites[key].image,
                spritesheet = sprites[key].spritesheet;

            if (!loader.resources[`image-${image}`]) {
                loader.add(`image-${image}`, `images/${image}.png`);
            }
            if (!loader.resources[`spritesheet-${spritesheet}`]) {
                loader.add(`spritesheet-${spritesheet}`, `spritesheets/${spritesheet}.json`);
            }
        }
    }
    spritesBy(key, value) {
        let results = {},
            k = Object.keys(this.sprites),
            l = k.length;

        while (l--) {
            if (this.sprites[k[l]][key] === value) {
                results[k[l]] = this.sprites[k[l]];
            }
        }
        return results;
    }
    useResources(resources, schema) {
        this.useSprites(resources, schema.sprites);
        this.useSounds(resources, schema.sounds);
        this.trigger('loaded');
    }
    useSprites(resources, sprites) {
        let k = Object.keys(sprites), l = k.length;

        while (l--) {
            let key = k[l],
                params = sprites[key],
                image = resources[`image-${params.image}`],
                spritesheet = resources[`spritesheet-${params.spritesheet}`].data,
                sprite = {
                    animations: {}
                },
                kss = Object.keys(spritesheet),
                lss = kss.length;

            while (lss--) {
                let spriteKey = kss[lss];

                if (spriteKey[0] === '_') {
                    sprite[spriteKey.substring(1)] = spritesheet[kss[lss]];
                } else {
                    sprite.animations[spriteKey] = this.constructSprite(spritesheet[spriteKey], image);
                }
            }
            this.sprites[key] = sprite;
        }
    }
    useSounds(resources, sounds) {
        sounds.forEach((sound) => {
            this.sounds[sound] = new Howl({
                urls: [resources[`sound-${sound}`].url],
                autoplay: false,
                loop: false,
                volume: 0.5
            });
        });
    }
}
export default Assets;

class CanvasLayer {
    constructor(params = {}) {
        this.entities = {};
        this.assets = params.assets || {};
        this.container = new PIXI.Container();
        this.container.zIndex = params.z || 1;
    }
    apply(index, member) {
        this.entities[index] = {
            setTexture(sheet, direction, index = 0) {
                let warning = '';

                if (!this.sprites[sheet]) {
                    warning = `The sheet \`${sheet}\` does not exist on CanvasLayer entity:`;
                } else if (!this.sprites[sheet].directions[direction]) {
                    warning = `The direction \`${direction}\` does not exist for sheet \`${sheet}\` on CanvasLayer entity:`;
                }
                if (warning) {
                    return console.warn(warning, this);
                } else {
                    this.sprite.texture = this.sprites[sheet].directions[direction][index];
                    return this.sprite.texture;
                }
            },
            member: member,
            sprite: new PIXI.Sprite(),
            sprites: this.spritesFor(member)
        };
        this.sync(this.entities[index]);
        this.container.addChild(this.entities[index].sprite);
    }
    spritesFor() {
        return {};
    }
    sync(entity) {
        entity.sprite.position.x = entity.member.x();
        entity.sprite.position.y = entity.member.y();
    }
    tick() {
        let k = Object.keys(this.entities),
            l = k.length;

        while (l--) {
            this.sync(this.entities[k[l]]);
        }
    }
}
export default CanvasLayer;

let CanvasLayer = require('./canvas-layer');

class Characters extends CanvasLayer {
    constructor(params) {
        super(params);
    }
    spritesFor(member) {
        return this.assets[member.archetype()].animations;
    }
    sync(entity) {
        super.sync(entity);
        let member = entity.member,
            origin = member.origin();

        if (member.health() <= 0) {
            entity.setTexture('dead', member.direction());
        }
        if (member.stance() === 0) {
            entity.setTexture('standing', member.direction());
        } else {
            entity.setTexture('walking', member.direction());
        }
    }
}
export default Characters;

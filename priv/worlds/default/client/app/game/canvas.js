let Characters = require('./characters');

class Canvas {
    constructor(params) {
        this.assets = params.assets;
        this.stage = new PIXI.Container();
        this.renderer = new PIXI.autoDetectRenderer(640, 480);
        $('#canvas-container').append(this.renderer.view);

        this.layers = {
            character: new Characters({
                assets: this.assets.spritesBy('type', 'character'),
                z: 1
            })
        };
        this.prepareCanvas();
    }
    addToLayer(layer, member, index) {
        if (this.layers[layer]) {
            this.layers[layer].apply(index, member);
        };
    }
    syncInLayer(layer, member, index) {
        if (this.layers[layer]) {
            this.layers[layer].sync(this.layers[layer].entities[index]);
        }
    }
    prepareCanvas() {
        let k = Object.keys(this.layers),
            l = k.length;

        while (l--) {
            this.stage.addChild(this.layers[k[l]].container);
        }
        this.updateLayersOrder();
    }
    tick() {
        let k = Object.keys(this.layers),
            l = k.length;

        while (l--) {
            this.layers[k[l]].tick();
        }
        this.renderer.render(this.stage);
    }
    updateLayersOrder() {
        this.stage.children.sort((a, b) => {
            a.zIndex = a.zIndex || 0;
            b.zIndex = b.zIndex || 0;

            return b.zIndex - a.zIndex;
        });
    }
};
export default Canvas;

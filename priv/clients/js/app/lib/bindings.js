const Events = require('./events'),
      Stage = require('./stage'),
      Stages = require('./stages'),
      Pools = require('./pools'),
      Utils = require('./utils');

class Bindings {
    constructor({bindings, parent}) {
        let k = Object.keys(bindings),
            l = k.length;

        this.client = {
            authenticated: bindings.authenticated || () => {},
            keydown: bindings.keydown || () => {},
            keypress: bindings.keypress || () => {},
            keyup: bindings.keyup || () => {},
            tick: Bindings.tick.bind(parent, bindings.tick || () => {}),
        };
        this.event = Events;
        this.stage = Stages;
        this.pool = Pools;

        Bindings.bindKeys.call(this, parent);
    }
    getKeyDown(parent, keyCode) {
        return parent.state.keysPressed.indexOf(keyCode) > -1;
    }
    keydownHandled(parent, e) {
        let prevent = this.client.keydown.apply(parent, [e, e.keyCode, !this.getKeyDown(e.keyCode)]);

        if (!this.getKeyDown(e.keyCode)) {
            this.setKeyDown(e.keyCode, parent, true);
        }
        if (prevent) {
            e.preventDefault();
            return false;
        }
        return true;
    }
    keyupHandled(parent, e) {
        if (this.getKeyDown(e.keyCode)) {
            this.setKeyDown(e.keyCode, parent, false);
        }
        return this.client.keyup.apply(parent, [e, e.keyCode]);
    }
    keypressHandled(parent, e) {
        return this.client.keypress.apply(parent, [e, e.keyCode]);
    }
    setKeyDown(keyCode, parent, isDown) {
        if (isDown) {
            parent.state.keysPressed.push(keyCode);
        } else {
            parent.state.keysPressed = parent.state.keysPressed.filter((code) => {
                return code !== keyCode;
            });
        }
    }
    static bindKeys(parent) {
        this.__proto__.getKeyDown = this.getKeyDown.bind(this, parent);

        ['keydown', 'keypress', 'keyup'].forEach((key) => {
            if (this.client[key] instanceof Function) {
                window.addEventListener(key, this[`${key}Handled`].bind(this, parent));
            } else {
                window.removeEventListener(key, this[`${key}Handled`].bind(this, parent));
            }
        });
    }
    static tick(callback, ...params) {
        Utils.entries(this.stages).forEach(([k, v]) => {
            Utils.entries(v).forEach(([k, v]) => {
                let pool = v;

                Utils.entries(v.transformations).forEach(([k, v]) => {
                    let attribute = k;

                    Utils.entries(v).forEach(([k, v]) => {
                        let index = k;

                        Utils.entries(v).forEach(([name, [type, amount]]) => {
                            switch (type) {
                            case 'lin':
                            default:
                                pool.members[index][attribute] = pool.members[index][attribute] + amount;
                            }
                        });
                    });
                });
            });
        });
        callback.apply(this, params);
    }
}
export default Bindings

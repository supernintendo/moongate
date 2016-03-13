const Stage = require('./stage'),
      Utils = require('./utils');

class Bindings {
    constructor(params) {
        let {bindings, parent} = params,
            k = Object.keys(bindings),
            l = k.length;

        while (l--) {
            let key = k[l];

            this[key] = bindings[key];
        }
        this.__proto__.getKeyDown = this.getKeyDown.bind(this, parent);
        Bindings.registerKeys.call(this, parent);
    }
    authenticated() {}
    keydown() {}
    keypress() {}
    keyup() {}
    tick() {}
    getKeyDown(parent, keyCode) {
        return parent.state.keysPressed.indexOf(keyCode) > -1;
    }
    keyupHandled(parent, e) {
        if (this.getKeyDown(e.keyCode)) {
            this.setKeyDown(e.keyCode, parent, false);
        }
        return this.keyup.apply(parent, [e, e.keyCode]);
    }
    keypressHandled(parent, e) {
        return this.keypress.apply(parent, [e, e.keyCode]);
    }
    keydownHandled(parent, e) {
        let prevent = this.keydown.apply(parent, [e, e.keyCode, !this.getKeyDown(e.keyCode)]);

        if (!this.getKeyDown(e.keyCode)) {
            this.setKeyDown(e.keyCode, parent, true);
        }
        if (prevent) {
            e.preventDefault();
            return false;
        }
        return true;
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
    eventsPacketHandled(event) {
        switch (event.action) {
        case 'set_token':
            this.state.authToken = event.params[0];
            this.callback('authenticated', []);
        default:
            break;
        }
    }
    stagePacketHandled(event) {
        switch (event.action) {
        case 'transaction':
            if (event.params[0] === 'join') {
                this.stages[event.id] = new Stage();
                this.callback('stageJoined', [event.id]);
            }
            return false;
        default:
            break;
        }
    }
    static registerKeys(parent) {
        ['keydown', 'keypress', 'keyup'].forEach((key) => {
            if (this[key] instanceof Function) {
                window.addEventListener(key, this[`${key}Handled`].bind(this, parent));
            } else {
                window.removeEventListener(key, this[`${key}Handled`].bind(this, parent));
            }
        });
    }
}
export default Bindings

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
    eventsSetToken(token) {
        this.state.authToken = token;
        this.callback('authenticated', []);
    }
    stageTransaction(action) {
        switch (action) {
        case 'define':
            return;
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

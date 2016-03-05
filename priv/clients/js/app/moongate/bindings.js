let Stage = require('./stage'),
    Utils = require('./utils');

class Bindings {
    constructor(params) {
        let {bindings, parent} = params;

        this.parent = parent;
        this.handlers = {};
        this.keysDown = [];
        this.registered = Utils.deepExtend(this.defaults(), bindings);
        this.handleKeys();
    }
    defaults() {
        return {
            authenticated: function() {},
            keydown: null,
            keypress: null,
            keyup: null,
            poolCreate: function(member, key, pool) {},
            poolSync: function(created, updated, pool) {
                this.poolSync.apply(this, arguments);
            },
            poolUpdate: function(member, key, pool) {},
            poolDrop: function(member, key, pool) {},
            stageJoin: function(state) {},
            tick: function() {}
        };
    }
    getKeyDown(keyCode) {
        return this.keysDown.indexOf(keyCode) > -1;
    }
    handleKeys() {
        ['keydown', 'keypress', 'keyup'].forEach((key) => {
            if (this.registered[key] instanceof Function) {
                window.addEventListener(key, this[`${key}Handled`].bind(this, this.parent));
            } else if (this.handlers[key]) {
                window.removeEventListener(key, this[`${key}Handled`].bind(this, this.parent));
            }
        });
    }
    keyupHandled(parent, e) {
        if (this.getKeyDown(e.keyCode)) {
            this.setKeyDown(e.keyCode, false);
        }
        return this.registered.keyup.apply(this.parent, [e, e.keyCode]);
    }
    keypressHandled(parent, e) {
        return this.registered.keypress.apply(this.parent, [e, e.keyCode]);
    }
    keydownHandled(parent, e) {
        let prevent = this.registered.keydown.apply(this.parent, [e, e.keyCode, !this.getKeyDown(e.keyCode)]);

        if (!this.getKeyDown(e.keyCode)) {
            this.setKeyDown(e.keyCode, true);
        }
        if (prevent) {
            e.preventDefault();
            return false;
        }
        return true;
    }
    setKeyDown(keyCode, isDown) {
        if (isDown) {
            this.keysDown.push(keyCode);
        } else {
            this.keysDown = this.keysDown.filter((code) => {
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
};

export default Bindings;

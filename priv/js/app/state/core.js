class MoongateState {
    constructor(params) {
        let {bindings} = params;

        this.authToken = 'anon';
        this.keysDown = [];
        this.ticks = false;
        this.bindingMap = this.defaults();
        this.bindings(bindings);
    }
    addHandler(namespace, callback) {
        this[this.handlerName(namespace)] = callback;
    }
    bindings(bindings) {
        if (!bindings) {
            return this.bindingMap;
        }
        this.bindingMap = Object.assign(this.bindingMap, bindings);
        this.handleKeys();
        return this.bindingMap;
    }
    defaults() {
        return {
            authenticated: function() {},
            keydown: null,
            keypress: null,
            keyup: null,
            poolCreate: function(member, key, pool) {},
            poolUpdate: function(member, key, pool) {},
            poolDrop: function(member, key, pool) {},
            stageJoin: function(state) {},
            tick: function() {}
        };
    }
    getKeyDown(keyCode) {
        return this.keysDown.indexOf(keyCode) > -1;
    }
    handlerFor(namespace) {
        let handlerName = this.handlerName(namespace);

        if (this[handlerName] && this[handlerName] instanceof Function) {
            return this[handlerName];
        }
        return false;
    }
    handlerName(namespace) {
        return `${namespace}PacketHandled`;
    }
    handleKeys() {
        ['keydown', 'keypress', 'keyup'].forEach((key) => {
            if (this.bindingMap[key] instanceof Function) {
                window.addEventListener(key, this[`${key}Handled`].bind(this));
            } else if (this.windowBindings[key]) {
                window.removeEventListener(key, this[`${key}Handled`].bind(this));
            }
        });
    }
    keyupHandled(e) {
        if (this.getKeyDown(e.keyCode)) {
            this.setKeyDown(e.keyCode, false);
        }
        return this.bindingMap.keyup(e, e.keyCode);
    }
    keypressHandled(e) {
        return this.bindingMap.keypress(e, e.keyCode);
    }
    keydownHandled(e) {
        let prevent = this.bindingMap.keydown(e, e.keyCode, !this.getKeyDown(e.keyCode));

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
    eventPacketHandled(event) {
        switch (event.action) {
        case 'set_token':
            this.state.authToken = event.params[0];
            return ['authenticated', []];
        default:
            break;
        }
    }
    stagePacketHandled(event) {
        switch (event.action) {
        case 'transaction':
            if (event.params[0] === 'join') {
                this.state.stage = event.id;
                return ['stageJoined', [event.id]];
            }
            return false;
        default:
            break;
        }
    }
}
export default MoongateState;

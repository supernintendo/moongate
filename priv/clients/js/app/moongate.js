const Bindings = require('./lib/bindings'),
      Console = require('./lib/console'),
      Dummy = require('./lib/dummy'),
      Packets = require('./lib/packets'),
      Pools = require('./lib/pools'),
      Pool = require('./lib/pool'),
      Stages = require('./lib/stages'),
      State = require('./lib/state'),
      Utils = require('./lib/utils');

class Moongate {
    constructor(bindings = {}, extensions = {}) {
        this['🔮'] = 'v0.1.1';
        this.connected = false;
        this.state = new State();
        this.stages = new Stages();
        this.bindings = new Bindings({
            bindings: bindings,
            parent: this
        });
        this.loop(extensions, (value, key) => {
            if (this[key]) {
                throw new Error(`key \`${key}\` is already implemented on Moongate and cannot be overriden.`);
            } else {
                this[key] = value;
            }
        });
        this.log('welcome', this['🔮']);
    }

    // Execute a State callback if it exists.
    callback(name, args) {
        if (this.bindings.client[name] instanceof Function) {
            return this.bindings.client[name].apply(this, args);
        }
        return false;
    }

    // Close the socket and cleanup.
    close() {
        if (this.socket) {
            this.socket.close();
            delete this.socket;
        }
        this.ping = null;
        this.connected = false;
        this.log('disconnected');

        return true;
    }

    // Given an ip and port, connect with WebSocket.
    connect(ip, port, callback) {
        this.socket = new WebSocket(`ws://${ip}:${port}`);
        this.socket.onclose = this.close.bind(this);
        this.socket.onopen = Moongate.connected.bind(this, callback);
        this.socket.onmessage = Moongate.receive.bind(this);

        return true;
    }

    log(label, ...params) {
        if (Console.dictionary[label]) {
            if (this.logs && (this.logs[label] || this.logs.all)) {
                Console.message(label, params);
            }
        } else {
            console.log.apply(console, arguments);
        }
    }

    // Given a username and password, send a login request.
    login(username, password) {
        this.state.username = username;

        this.send(':auth', 'login', username, password);
    }

    // Fast loop
    loop(obj, callback) {
        let k = Object.keys(obj),
            l = k.length;

        while (l--) {
            callback(obj[k[l]], k[l]);
        }
    }

    keysPressed(...keys) {
        let keysPressed = this.state.keysPressed;

        return keys.some((key) => keysPressed.indexOf(key) > -1);
    }

    keysAllPressed(...keys) {
        let keysPressed = this.state.keysPressed;

        return keys.every((key) => keysPressed.indexOf(key) > -1);
    }

    keysNotPressed(...keys) {
        let keysPressed = this.state.keysPressed;

        return keys.every((key) => keysPressed.indexOf(key) === -1);
    }

    // Assign a name in the binding map to a callback.
    register(namespace, callback) {
        this.bindings[namespace] = callback;
    }

    // Send a prepared packet to the server.
    send(...parts) {
        if (!this.connected) {
            return console.warn('Moongate is not connected. Please refresh the page to reconnect.');
        }
        if (parts.length === 0) {
            return false;
        }
        let delimiter = this.delimiter || '·',
            outgoing = Packets.outgoing(delimiter, parts);

        if (outgoing) {
            return this.socket.send(outgoing);
        }
    }

    stage(name) {
        if (this.stages[name]) {
            return this.stages[name];
        }
        return new Dummy();
    }

    // Execute a callback on tick.
    tick(...params) {
        this.callback('tick', params);

        window.requestAnimationFrame(() => {
            this.tick.apply(this, params);
        });
    }

    // Execute the appropriate callback for a packet.
    use(parts) {
        let event = Packets.parse(parts, {authToken: this.state.authToken}),
            callbackName = Utils.camelize(event.action),
            scope = this.bindings[event.from];

        if (scope && scope[callbackName] instanceof Function) {
            let result = scope[callbackName].apply(this, event.params),
                callback = this.bindings.client[event.from] && this.bindings.client[event.from][callbackName];

            if (callback && callback instanceof Function) {
                if (result instanceof Array) {
                    result = callback.apply(this, result);
                } else {
                    result = callback.apply(this, [result]);
                }
            }
            return result;
        }
    }

    static connected(callback) {
        this.connected = true;
        this.log('connected', this.socket.url);

        if (callback instanceof Function) {
            return callback();
        }
        return true;
    }

    // Receive a packet from the server, making use of the parts.
    static receive(e) {
        let parts = Packets.unravel(e.data);

        if (parts.length > 0) {
            let [time, target, action, ...params] = parts;

            Moongate.updatePing(time);

            this.use(parts);
        }
    }

    // Update ping with calculated latency.
    static updatePing(time) {
        this.ping = Date.now() - time;
    }
}

export default Moongate

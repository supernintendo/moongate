const Bindings = require('./moongate/bindings'),
      Console = require('./moongate/console'),
      Packets = require('./moongate/packets'),
      Pools = require('./moongate/pools'),
      Pool = require('./moongate/pool'),
      Stages = require('./moongate/stages'),
      State = require('./moongate/state'),
      Utils = require('./moongate/utils');

class Moongate {
    constructor(bindings = {}, extensions = {}) {
        this['🔮'] = 'v0.1.0';
        this.status = 'disconnected';
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
        if (this.bindings[name] instanceof Function) {
            return this.bindings[name].apply(this, args);
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
        this.status = 'disconnected';
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
        this.send('auth', 'login', username, password);
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
        if (this.status !== 'connected') {
            return console.warn('Moongate is not connected. Please refresh the page to reconnect.');
        }
        let delimiter = this.delimiter || '·',
            outgoing = Packets.outgoing(delimiter, parts);

        if (outgoing) {
            this.log('outgoingPacket', outgoing);

            return this.socket.send(outgoing);
        }
    }

    // Execute a callback on tick.
    tick(tick, params = []) {
        this.callback('tick', params);

        if (tick) {
            this.state.ticking = true;
        }
        if (this.state.ticking) {
            window.requestAnimationFrame(this.tick.bind(this, null, params));
        }
    }

    // Execute the appropriate callback for a packet.
    use(parts) {
        let event = Packets.parse(parts, {authToken: this.state.authToken}),
            callbackName = Moongate.callbackNameForEvent(event);

        if (this.bindings[callbackName] && this.bindings[callbackName] instanceof Function) {
            this.bindings[callbackName].apply(this, [event.id].concat(event.params));
        }
    }

    static callbackNameForEvent(event) {
        return Utils.camelize(`${event.from}${Utils.uppercase(event.action)}`);
    }

    static connected(callback) {
        this.status = 'connected';
        this.log('connected');

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
        this.log('incomingPacket', e.data);
    }

    // Update ping with calculated latency.
    static updatePing(time) {
        this.ping = Date.now() - time;
    }
}
export default Moongate

let Bindings = require('./moongate/bindings'),
    Packets = require('./moongate/packets'),
    Pools = require('./moongate/pools'),
    Pool = require('./moongate/pool'),
    State = require('./moongate/state');

class Moongate {
    constructor(bindings, extensions = {}) {
        this['🔮'] = 'v0.1.0';
        this.status = 'disconnected';
        this.pools = new Pools();
        this.state = new State();
        this.bindings = new Bindings({
            bindings: bindings,
            parent: this
        });
        this.register('events', this.bindings.eventsPacketHandled);
        this.register('stage', this.bindings.stagePacketHandled);
        this.loop(extensions, (value, key) => {
            if (this[key]) {
                throw new Error(`key \`${key}\` is already implemented on Moongate and cannot be overriden.`);
            } else {
                this[key] = value;
            }
        });
    }

    // Execute a State callback if it exists.
    callback(name, args) {
        if (this.bindings.registered[name] instanceof Function) {
            return this.bindings.registered[name].apply(this, args);
        }
        return false;
    }

    // Close the socket and cleanup.
    close() {
        this.socket.close();
        delete this.socket;
        this.ping = null;
        this.status = 'disconnected';

        return true;
    }

    // Given an ip and port, connect with WebSocket.
    connect(ip, port, callback) {
        this.socket = new WebSocket(`ws://${ip}:${port}`);
        this.socket.onclose = this.close;
        this.socket.onopen = this.connected.bind(this, callback);
        this.socket.onmessage = this.receive.bind(this);

        return true;
    }

    // Once connected, set status and execute callback.
    connected(callback) {
        this.status = 'connected';

        if (callback instanceof Function) {
            return callback();
        }
        return true;
    }

    // Given a username and password, send a login request.
    login(username, password) {
        this.send(`auth login ${username} ${password}`);
    }

    // Fast loop
    loop(obj, callback) {
        let k = Object.keys(obj),
            l = k.length;

        while (l--) {
            callback(obj[k[l]], k[l]);
        }
    }

    keysAreDown(...keys) {
        let keysDown = this.bindings.keysDown;

        return keys.some((key) => keysDown.indexOf(key) > -1);
    }

    keysAreAllDown(...keys) {
        let keysDown = this.bindings.keysDown;

        return keys.every((key) => keysDown.indexOf(key) > -1);
    }

    keysAreNotDown(...keys) {
        let keysDown = this.bindings.keysDown;

        return keys.every((key) => keysDown.indexOf(key) === -1);
    }

    poolSync(created, updated, pool) {
        this.loop(created, (member, key) => {
            this.bindings.registered.poolCreate.apply(this, [member, key, pool]);
        });
        this.loop(updated, (member, key) => {
            this.bindings.registered.poolUpdate.apply(this, [member, key, pool]);
        });
    }

    // Assign a name in the binding map to a callback.
    register(namespace, callback) {
        this.bindings.registered[namespace] = callback;
    }

    // Send a prepared packet to the server.
    send(packet) {
        return this.socket.send(Packets.outgoing(packet));
    }

    // Send a prepared packet to the server, targeting a stage.
    stageSend(message) {
        if (message) {
            this.send(`${this.state.stage} ${message}`);
        }
    }

    // Receive a packet from the server, making use of the parts.
    receive(e) {
        let parts = Packets.unravel(e.data);

        if (parts.length > 0) {
            let [time, target, action, ...params] = parts;

            this.updatePing(time);
            this.use(parts);
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

    // Update ping with calculated latency.
    updatePing(time) {
        this.ping = Date.now() - time;
    }

    // Execute the appropriate callback for a packet.
    use(parts) {
        let event = Packets.parse(parts, {authToken: this.state.authToken});

        switch (event.from) {
        case 'events':
        case 'stage':
            return this.callback(event.from, [event]);
        case 'pool':
            let results = Pool.use(event, this.pools);

            if (results) {
                return this.callback(results.callback, results.params);
            }
        default:
            return false;
        }
    }
};

export default Moongate;

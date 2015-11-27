let Packets = require('./packets/core'),
    Pools = require('./pools/core'),
    State = require('./state/core');

class Moongate {
    constructor(bindings) {
        this.pools = {};
        this.state = new State(bindings);
        this.status = 0;

        this.socket = null;
        this.ping = null;
        console.log('%c ☪ moongate.js v0.1.0 ', 'background: #151718; color: #C065DB');
    }

    // Execute a State callback if it exists.
    callback(params) {
        let [name, args] = params;

        if (this.state.bindingMap[name] instanceof Function) {
            return this.state.bindingMap[name](args);
        }
        return false;
    }

    // Close the socket and cleanup.
    close() {
        this.socket.close();
        this.socket = null;
        this.ping = null;
        this.status = 0;

        return true;
    }

    // Given an ip and port, connect with WebSocket.
    connect(ip, port, callback) {
        this.socket = new WebSocket(`ws://${ip}:${port}`);
        this.socket.onclose = this.close;
        this.socket.onopen = this.connected.bind(this, callback);
        this.socket.onmessage = this.receive;

        return true;
    }

    // Once connected, set status and execute callback.
    connected(callback) {
        this.status = 1;

        if (callback instanceof Function) {
            return callback();
        }
        return true;
    }

    // Given a username and password, send a login request.
    login(username, password) {
        this.send(`auth login ${username} ${password}`);
    }

    // Send a prepared packet to the server.
    send(packet) {
        return this.socket.send(Packets.outgoing(packet));
    }

    // Send a prepared packet to the server, targeting a stage.
    stageSend(message) {
        this.send(`${this.state.stage} ${message}`);
    }

    // Return a string describing the current socket status.
    status() {
        switch (this.status) {
        case 0:
            return 'disconnected';
        case 1:
            return 'connected';
        case 2:
            return 'reconnecting';
        default:
            return 'unknown';
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

    // Register a callback to a packet namespace.
    register(namespace, callback) {
        let handler = State.handlerFor(namespace);

        if (handler) {
            console.warn(`Moongate: Cannot register callback ${namespace} as it has already been registered.`);
        } else {
            this.state.addHandler(namespace, callback);
        }
    }

    // Execute a callback on tick.
    tick(tick) {
        this.callback('tick', []);

        if (tick) {
            this.state.ticks = true;
        }
        if (this.state.ticks) {
            window.requestAnimationFrame(this.tick.bind(this));
        }
    }

    // Update ping with calculated latency.
    updatePing(time) {
        this.ping = Date.now() - time;
    }

    // Execute the appropriate callback for a packet.
    use(parts) {
        let event = Packets.parse(parts, {authToken: this.state.authToken}),
            namespace = event.namespace,
            handler = State.handlerFor(namespace);

        switch (namespace) {
        case 'events':
        case 'stage':
            if (handler) {
                return this.callback(handler(event));
            }
        case 'pool':
            let results = Pools.use(event, this.pools);

            return this.callback(results);
        default:
            return false;
        }
    }
};
export default Moongate;

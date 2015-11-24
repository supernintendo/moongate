(function() {
    var MoongateApp = function(app) {
        var defaults = {
            authenticated: function() {},
            keydown: function(e) {},
            keypress: function(e) {},
            keyup: function(e) {},
            poolMemberAdded: function(member, key, pool) {},
            poolMemberUpdated: function(member, key, pool) {},
            poolMemberRemoved: function(member, key, pool) {},
            stageJoined: function(stage) {},
            tick: function() {}
        }, k = Object.keys(defaults), l = k.length;

        while (l--) {
            this[k[l]] = app[k[l]] || defaults[k[l]];
        }
    };
    var MoongateState = function() {
        this.authToken = 'anon';
        this.callbacks = {};
        this.connected = false;
        this.keyboard = {
            keysDown: []
        };
        this.ping = 0;
        this.stage = null;
        this.ticks = false;
    };
    var MoongatePools = function() {};
    var MoongatePool = function(attributes) {
        this.attributes = attributes;
        this.members = {};
    };
    Moongate = function(app) {
        this.state = new MoongateState();
        this.pools = new MoongatePools();
        this.app = new MoongateApp(app);
        this.register('events', this.useEventsPacket);
        this.register('pool', this.usePoolPacket);
        this.register('stage', this.useStagePacket);
        this.bindKeyboard();
        this.socket = null;
        console.log('%c ☪ moongate.js v0.01 ', 'background: #151718; color: #C065DB');
    };
    Moongate.prototype.addToPool = function(pool, keys, values, isNew, latency) {
        var i,
            l = values.length - 1,
            member = this.pools[pool].members[values[0]] || {},
            params,
            value;

        while (l--) {
            value = this.valueForType(values[l + 1], this.pools[pool].attributes[keys[l]], latency);

            member[keys[l]] = value;
        }
        member.get = this.getFromPoolMember.bind(this, pool, values[0]);
        this.pools[pool].members[values[0]] = member;

        params = [member, values[0], pool];
        isNew ? this.app.poolMemberAdded.apply(this.app, params) : this.app.poolMemberUpdated.apply(this.app, params);

        return member;
    };
    Moongate.prototype.bindKeyboard = function() {
        var done, gate = this;

        window.addEventListener('keyup', function(e) {
            if (gate.keyIsDown(e.keyCode)) {
                gate.setKeyDownState(e.keyCode, false);
            }
            gate.app.keyup(e, e.keyCode);
        }.bind(this), false);
        window.addEventListener('keypress', function(e) {
            gate.app.keypress(e, e.keyCode);
        }.bind(this), false);
        window.addEventListener('keydown', function(e) {
            done = gate.app.keydown(e, e.keyCode, !gate.keyIsDown(e.keyCode));
            if (!gate.keyIsDown(e.keyCode)) {
                gate.setKeyDownState(e.keyCode, true);
            }
            if (done) {
                e.preventDefault();
                return false;
            }
        }.bind(this), false);
    };
    Moongate.prototype.callback = function(callback, params) {
        if (this.app[callback] && typeof this.app[callback] === 'function') {
            this.app[callback].apply(this, params);
        }
    };
    Moongate.prototype.cleanUp = function() {
        this.socket.close();
        this.socket = null;
    };
    Moongate.prototype.close = function() {
        this.state.connected = false;
        this.cleanUp();
    };
    Moongate.prototype.connect = function(ip, port, callback) {
        this.socket = new WebSocket('ws://' + ip + ':' + port);
        this.socket.onclose = this.close.bind(this);
        this.socket.onopen = this.open.bind(this, callback);
        this.socket.onmessage = this.receive.bind(this);
    };
    Moongate.prototype.describePool = function(id, description) {
        if (this.pools[id]) {
            return;
        }
        var attributes = {}, parts;

        description.split('¦').forEach(function(attribute) {
            parts = attribute.split(':');

            if (parts[0] && parts[1]) {
                attributes[parts[0]] = parts[1];
            }
        });
        this.pools[id] = new MoongatePool(attributes);
    };
    Moongate.prototype.getFromPoolMember = function(pool, index, attribute) {
        if (!this.pools[pool].members[index])  {
            return null;
        }
        var value = this.pools[pool].members[index][attribute];

        if (value && value.transforms && value.transforms.length > 0) {
            return this.transformedValue(value);
        }
        if (value) {
            return value.precise;
        }
    };
    Moongate.prototype.keyIsDown = function(keyCode) {
        return this.state.keyboard.keysDown.indexOf(keyCode) > -1;
    };
    Moongate.prototype.login = function(username, password) {
        this.send('auth login ' + username + ' ' + password);
    };
    Moongate.prototype.isValid = function(packet) {
        /* Make sure the packet length is correct.
         */
        return Number(packet[0]) === packet[1].replace(/░/g, '').length;
    };
    Moongate.prototype.open = function(callback) {
        this.state.connected = true;

        if (callback) {
            callback();
        }
    };
    Moongate.prototype.parse = function(parts) {
        var namespace = parts[1].split('_');

        this.state.ping = parts[0];

        return {
            action: parts[2],
            id: namespace.slice(1).join('_'),
            latency: Date.now() - parts[0],
            from: namespace[0],
            params: parts.slice(3)
        };
    };
    Moongate.prototype.send = function(packet) {
        var length = packet.replace(/\s/g, '').length;

        this.socket.send(length + '{' + packet + '}');
    };
    Moongate.prototype.setKeyDownState = function(keyCode, isDown) {
        if (isDown) {
            this.state.keyboard.keysDown.push(keyCode);
        } else {
            this.state.keyboard.keysDown = this.state.keyboard.keysDown.filter(function(code) {
                return code !== keyCode;
            });
        }
    };
    Moongate.prototype.stageSend = function(message) {
        this.send(this.state.stage + ' ' + message);
    };
    Moongate.prototype.sync = function(pool, params, latency) {
        if (!this.pools[pool]) {
            return;
        }
        var parts = params.split(':'),
            batch = parts.slice().splice(1).join(':'),
            attributes = parts[0].split('¦'),
            members = batch.split('„').map(function(member) {
                return member.split('¦');
            }),
            l = members.length,
            index,
            member;

        while (l--) {
            index = members[l][0];

            if (members[l].length - 1 === attributes.length) {
                var isNew = !this.pools[pool].members[index];
                this.addToPool(pool, attributes, members[l], isNew, latency);
            }
        }
    };
    Moongate.prototype.receive = function(e) {
        /* Take a packet and if it is valid, do stuff with
         it. */
        var packet = e && e.data && e.data.split(/{(.*?)}/g),
            parts = packet && packet[1].split('░');

        if (this.isValid(packet)) {
            if (parts[1].split('_').length > 0) {
                this.use(this.parse(parts));
            }
        }
    };
    Moongate.prototype.removeFromPool = function(pool, index) {
        var member = this.pools[pool].members[index];

        if (member) {
            this.app.poolMemberRemoved(member, index, pool);
            delete this.pools[pool].members.index;
        }
    };
    Moongate.prototype.register = function(from, callback) {
        if (this.state.callbacks[from]) {
            console.warn("Moongate: Cannot register callback '" + from + "' as it has already been registered.");
        } else {
            this.state.callbacks[from] = callback.bind(this);
        }
    };
    Moongate.prototype.transformsFrom = function(transforms) {
        return transforms.map(function(transform) {
            return transform.split(':');
        });
    };
    Moongate.prototype.transformedValue = function(value) {
        var precise = value.precise,
            transforms = value.transforms,
            added = 0,
            l = transforms.length;

        while(l--) {
            added += (Date.now() + value.latency - value.started) * transforms[l][1];
        }
        return precise + added;
    };
    Moongate.prototype.tick = function(tick) {
        this.callback('tick', []);

        if (tick) {
            this.state.ticks = true;
        }
        if (this.state.ticks) {
            window.requestAnimationFrame(this.tick.bind(this));
        }
    };
    Moongate.prototype.use = function(packet) {
        var from = packet.from;

        if (this.state.callbacks[from]) {
            this.state.callbacks[from](packet);
        } else {
            console.warn("Moongate: No callback for '" + from + "'.");
        }
    };
    Moongate.prototype.useEventsPacket = function(packet) {
        switch (packet.action) {
        case 'set_token':
            this.state.authToken = packet.params[0];
            this.callback('authenticated', []);
            break;
        default:
            break;
        }
    };
    Moongate.prototype.useStagePacket = function(packet) {
        switch (packet.action) {
        case 'transaction':
            if (packet.params[0] === 'join') {
                this.state.stage = packet.id;
                this.callback('stageJoined', [packet.id]);
            }
            break;
        default:
            break;
        }
    };
    Moongate.prototype.usePoolPacket = function(packet) {
        switch (packet.action) {
        case 'drop':
            this.removeFromPool(packet.id, packet.params[0]);
            break;
        case 'sync':
            var update = this.sync(packet.id, packet.params[0], packet.latency);
            break;
        case 'describe':
            this.describePool(packet.id, packet.params[0]);
            break;
        default:
            break;
        }
    };
    Moongate.prototype.valueForType = function(value, type, latency) {
        var parts = value.split('›'),
            precise = parts[0],
            transforms = this.transformsFrom(parts.slice(1));

        switch (type) {
        case 'float':
            return {
                latency: latency,
                precise: parseFloat(precise),
                started: Date.now(),
                transforms: transforms
            };
        case 'int':
            return {
                latency: latency,
                precise: Math.round(precise),
                started: Date.now(),
                transforms: transforms
            };
        case 'string':
            return {
                latency: latency,
                precise: value,
                started: Date.now(),
                transforms: null
            };
        case 'origin':
            return {
                latency: latency,
                precise: value,
                owned: value === this.state.authToken,
                started: Date.now(),
                transforms: null
            };
        default:
            return null;
        }
    };
})();

(function(exports) {
    // Classes
    function Ring() {}
    function Entity() {}
    function Zone() {}

    // Class behavior
    var behavior = {
        ring: {
            contents: [],
            all: function() {
                return this.contents;
            },
            findBy: function(key, value) {
                return this.contents.filter(function(member) {
                    return member[key] === value;
                })[0] || null;
            }
        },
        ws: {
            onopen: function() {
                return this.callback('connected', {});
            },
            onmessage: function(e) {
                var packet = this.readPacket(e.data),
                    callbackName = packet.command + capitalize(packet.domain);

                return this.callback(callbackName, packet);
            },
            onclose: function() {
                return this.callback('disconnected', {});
            }
        },
        zone: {
            all: function(ring) {
                if (this[ring]) {
                    return this[ring].contents;
                }
            }
        }
    };

    //
    // Helper functions
    //

    function capitalize(string) {
        return string.charAt(0).toUpperCase() + string.slice(1);
    }

    // Assign all attributes on one object to another.
    function decorate(object, changes, context) {
        Object.keys(changes).forEach(function(key) {
            if (object instanceof Function) {
                object = changes[key].bind(context || object);
            } else {
                object = changes[key];
            }
        });

        return object;
    }

    function generateToken() {
        return new Date().getTime();
    }

    // Assign all attributes on one object to the
    // prototype of another.
    function inherit(object, changes, context) {
        Object.keys(changes).forEach(function(key) {
            if (object.__proto__[key] instanceof Function) {
                object.__proto__[key] = changes[key].bind(context || object);
            } else {
                object.__proto__[key] = changes[key];
            }
        });

        return object;
    }

    function registerOperation(code, operation) {
        this.operations[code] = operation;
    }

    //
    // Moongate instance
    //

    // Initialization
    exports.__proto__.init = function() {
        this['__🔮__'] = null;
        this.ws = null;
        this.callbacks = {};
        this.token = generateToken();
        this.operations = {};
        this.rings = {};
        this.zones = {};
        this.connect();
    }

    // HTTP
    exports.__proto__.request = function(type, url, callback) {
        var request = new XMLHttpRequest();

        if (callback) {
            request.onload = callback;
        }
        request.open(type, url);

        return request.send();
    }
    exports.__proto__.delete = function(url, callback) {
        return this.request('DELETE', url, callback);
    }
    exports.__proto__.get = function(url, callback) {
        return this.request('GET', url, callback);
    }
    exports.__proto__.post = function(url, callback) {
        return this.request('POST', url, callback);
    }
    exports.__proto__.put = function(url, callback) {
        return this.request('PUT', url, callback);
    }

    // WebSockets

    // Request the handshake.json and use it to connect
    // via WebSocket.
    exports.__proto__.connect = function() {
        this.request('GET', 'handshake.json', function(e) {
            var handshake = JSON.parse(e.target.response);

            this['__🔮__'] = handshake.version;
            this.loop(handshake.operations || {}, registerOperation.bind(this));
            this.ws = new WebSocket('ws://' + handshake.ip + ':' + handshake.sockets.ws);
            this.ws.onopen = behavior.ws.onopen.bind(this);
            this.ws.onmessage = behavior.ws.onmessage.bind(this);
            this.ws.onclose = behavior.ws.onclose.bind(this);
        }.bind(this));
    }
    exports.__proto__.constructPacket = function(body, params) {
        var targetId = (params.targetId && '_' + params.targetId) || '',
            zoneId = (params.zoneId && '_' + params.zoneId) || '_$',
            zone = (params.zone) ? ('@' + params.zone + zoneId) : '';

        return {
            body: (body instanceof Array) ? body.join(' ') : body,
            domain: (params.domain && params.domain + ':') || '',
            target: (params.target && '<' + params.target + targetId + zone + '>') || ''
        };
    }
    exports.__proto__.send = function(packet) {
        this.ws.send(packet);
    }
    exports.__proto__.readPacket = function(packet) {
        var parts = packet.split('::'),
            context = parts[0].match(/\(([^)]+)\)/)[1].split(':'),
            target = parts[0].match(/\<([^)]+)\>/)[1].split('@');

        return {
            body: parts.slice(1).join(''),
            domain: context[0],
            command: this.operations[parseInt(context[1], 16)],
            ring: target.length > 1 ? target[0] : null,
            zone: target[target.length - 1].split('_')[0],
            zoneId: target[target.length - 1].split('_').slice(1).join('_')
        };
    }

    //
    // Events
    //

    // Call a callback in this.callbacks if it exists.
    exports.__proto__.callback = function(callbackName, packet) {
        if (this[callbackName]) {
            var result = this[callbackName](packet);

            if (this.callbacks[callbackName]) {
                this.callbacks[callbackName](result);
            }
        } else if (this.callbacks[callbackName]) {
            this.callbacks[callbackName](packet);
        }
    }
    // This is called every frame.
    exports.__proto__.tick = function() {
        window.requestAnimationFrame(this.tick.bind(this));
    }

    //
    // State
    //
    exports.__proto__.addRing = function(packet) {
        var member = packet.body.split(',').reduce(function(member, attribute, index) {
            if (index === 0) {
                member.__proto__.index = parseInt(attribute, 10);

                return member;
            } else {
                if (this.rings[packet.ring].attributes[index - 1]) {
                    var spec = this.rings[packet.ring].attributes[index - 1];

                    switch (spec.type) {
                        case 'float':
                            member[spec.key] = parseFloat(attribute);

                            break;
                        default:
                            member[spec.key] = attribute;
                    }
                    return member;
                }
            }
        }.bind(this), new Entity());
        this.zones[packet.zone][packet.zoneId][packet.ring].contents.push(member);

        return member;
    }
    exports.__proto__.joinRing = function(packet) {
        var attributes = packet.body.split(' ').map(function(pair) {
            var parts = pair.split(':');

            return {
                key: parts[0],
                type: parts[1]
            }
        });
        this.touchRing(packet.ring);
        this.rings[packet.ring].attributes = attributes;
    }
    exports.__proto__.joinZone = function(packet) {
        var rings = packet.body.split(','),
            l = rings.length;

        this.touchZone(packet.zone, packet.zoneId);

        while (l--) {
            this.touchRing(rings[l]);
            this.touchZoneRing(packet.zone, rings[l], Object.keys(this.zones[packet.zone]));
        }
    }
    exports.__proto__.touchRing = function(ringName) {
        if (!this.rings[ringName]) {
            this.rings[ringName] = {};
        }
    }
    exports.__proto__.touchZone = function(zoneName, zoneId) {
        if (!this.zones[zoneName]) {
            this.zones[zoneName] = new Zone();
        }
        if (zoneId && !this.zones[zoneName][zoneId]) {
            this.zones[zoneName][zoneId] = inherit(new Zone(), behavior.zone);
        }
    }

    // Create an instance of a ring within a zone.
    // z : zone name, r : ring name
    exports.__proto__.touchZoneRing = function(z, r, keys) {
        var zoneKeys = keys || Object.keys(this.zones[z]),
            l = zoneKeys.length;

        while (l--) {
            if (!this.zones[z][zoneKeys[l]][r]) {
                this.zones[z][zoneKeys[l]][r] = new Ring();
                inherit(this.zones[z][zoneKeys[l]][r], behavior.ring);
                decorate(this.zones[z][zoneKeys[l]][r], {
                    contents: []
                });
            }
        }
    }

    exports.__proto__.zone = function(name, id) {
        if (id && this.zones[name]) {
            return this.zones[name][id] || null;
        }
        return this.zones[name] || null;
    }

    //
    // Utility
    //

    // Reverse while loop.
    exports.__proto__.loop = function(arrayOrObject, callback) {
        if (typeof arrayOrObject === 'object') {
            var k = Object.keys(arrayOrObject),
                l = k.length;

            while (l--) {
                callback(arrayOrObject[k[l]], k[l]);
            }
        } else {
            var l = arrayOrObject.length;

            while (l--) {
                callback(arrayOrObject[l]);
            }
        }
    }
})(typeof exports === 'undefined'? this['Moongate']=(function() {
    return new function Moongate() {};
})(): exports);

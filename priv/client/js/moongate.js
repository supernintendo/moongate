(function(exports) {
    //
    // Core functionality
    //
    var Core = {
        capitalize: function(string) {
            return string.charAt(0).toUpperCase() + string.slice(1);
        },
        decimalToHex: function(d, padding) {
            var hex = Number(d).toString(16);

            padding = typeof (padding) === "undefined" || padding === null ? padding = 2 : padding;

            while (hex.length < padding) {
                hex = "0" + hex;
            }
            return hex;
        },
        decorate: function(object, changes, context) {
            Object.keys(changes).forEach(function(key) {
                if (changes[key] instanceof Function) {
                    object[key] = changes[key].bind(context || object);
                } else {
                    object[key] = changes[key];
                }
            });

            return object;
        },
        domainFromPayload: function(payload) {
            if (payload.target) {
                if (payload.target.ringName) {
                    return 'ring';
                } else if (payload.target.ZoneName) {
                    return 'zone';
                }
            }
            return 'world';
        },
        extend(target, source, shallow) {
            var array = '[object Array]',
                object = '[object Object]',
                targetMeta, sourceMeta,
                setMeta = function (value) {
                    var meta,
                        jclass = {}.toString.call(value);

                    if (value === undefined) {
                        return 0
                    };
                    if (typeof value !== 'object') {
                        return false
                    };
                    if (jclass === array) {
                        return 1;
                    }
                    if (jclass === object) {
                        return 2
                    };
                };

            for (var key in source) {
                if (source.hasOwnProperty(key)) {
                    targetMeta = setMeta(target[key]);
                    sourceMeta = setMeta(source[key]);

                    if (source[key] !== target[key]) {
                        if (!shallow && sourceMeta && targetMeta && targetMeta === sourceMeta) {
                            target[key] = extend(target[key], source[key], true);
                        } else if (sourceMeta !== 0) {
                            target[key] = source[key];
                        }
                    }
                }
                else break;
            }
            return target;
        },
        inherit: function(object, changes, context) {
            Object.keys(changes).forEach(function(key) {
                if (object.__proto__[key] instanceof Function) {
                    object.__proto__[key] = changes[key].bind(context || object);
                } else {
                    object.__proto__[key] = changes[key];
                }
            });

            return object;
        },
        matchPacketChunk: function(chunk, key) {
            var match = chunk.match(Patterns[key]),
                parts = [];

            if (match && match[1]) {
                parts = match[1].split(':');

                if (parts.length === 1) {
                    return parts[0];
                }
                return parts;
            }
            return null;
        },
        registerOperation: function(code, operation) {
            this.operations[code] = operation;
        },
        parsePacketCallbackName: function(packet) {
            var op;

            if (packet.domain instanceof Array) {
                op = this.operations[parseInt(packet.domain[0], 16)];

                return op + Core.capitalize(packet.domain[1]);
            }
            op = this.operations[parseInt(packet.domain, 16)];

            return op + 'Operation';
        },
        preparePacketBody: function(body, suffix) {
            if (body) {
                if (typeof body === 'object') {
                    return '::' + JSON.stringify(body);
                }
                return '::' + body;
            }
        },
        splitPacketChunk: function(chunk, key) {
            var match = chunk.split(Patterns[key]);

            return match.slice(1).join('');
        },
        touchRing: function(packet) {
            if (!this.rings[packet.ring]) {
                this.rings[packet.ring] = JSON.parse(packet.body);
            }
        },
        touchZone: function(packet) {
            var zoneName, zoneId;

            if (packet.zone instanceof Array) {
                zoneName = packet.zone[0],
                zoneId = packet.zone[1];

                if (!this.zones[zoneName]) {
                    this.zones[zoneName] = new Zones();
                }
                if (!this.zones[zoneName][zoneId]) {
                    this.zones[zoneName][zoneId] = new Zone();
                    Core.inherit(this.zones[zoneName][zoneId], Behavior.zone);

                    if (packet.body) {
                        Core.touchZoneRings.call(this, packet);
                    }
                }
            } else {
                this.zones[packet.zone] = new Zones();
            }
        },
        touchZoneRings: function(packet) {
            var zoneName = packet.zone[0],
                zoneId = packet.zone[1],
                rings = packet.body.split(',');
                l = rings.length;

            while (l--) {
                this.zones[zoneName][zoneId][rings[l]] = new Ring();
                Core.decorate(this.zones[zoneName][zoneId][rings[l]], {
                    members: {}
                });
                Core.inherit(this.zones[zoneName][zoneId][rings[l]], {
                    payload: {
                      domain: 'ring',
                      ring: rings[l],
                      zone: [zoneName, zoneId]
                    }
                });
                Core.inherit(this.zones[zoneName][zoneId][rings[l]], Behavior.ring);
                Core.inherit(this.zones[zoneName][zoneId][rings[l]], Behavior.operations.call(this));
            }
        },
        wrapPacketChunk: function(chunk, left, right) {
            if (chunk) {
                if (chunk instanceof Array) {
                    return left + chunk.join(':') + right;
                }
                return left + chunk + right;
            }
            return '';
        },
        writePacket: function(context, opCode, params) {
            context.send(context.writePacket({
                body: params.body,
                deed: params.deed,
                domain: [opCode, this.payload.domain],
                ring: this.payload.ring,
                zone: this.payload.zone,
            }));
        }
    }

    //
    // Classes
    //
    function Ring() {}
    function Entity() {}
    function Zones() {}
    function Zone() {}

    //
    // Behavior
    //
    var Behavior = {
        ring: {
            members: {},
            all: function() {
                return this.members;
            },
            findBy: function(key, value) {
                return this.members.filter(function(member) {
                    return member[key] === value;
                })[0] || null;
            }
        },
        operations: function() {
            var i,
                gate = this,
                result = {},
                k = Object.keys(this.operations),
                l = k.length;

            Object.keys(this.operations).forEach(function(i) {
                result[this.operations[i]] = function() {
                    var args = Array.prototype.slice.call(arguments);

                    Core.writePacket.call(this, gate, Core.decimalToHex(i), {
                        body: args.slice(1).join('░'),
                        deed: args[0]
                    });
                };
            }, this);

            return result;
        },
        ws: {
            onopen: function() {
                this.send(this.writePacket({
                    body: 'init',
                    domain: this.operation('request')
                }))

                return this.callback('connected', {});
            },
            onmessage: function(e) {
                var packet = this.readPacket(e.data),
                    callbackName = Core.parsePacketCallbackName.call(this, packet);

                return this.callback(callbackName, packet);
            },
            onclose: function() {
                return this.callback('disconnected', {});
            }
        },
        zone: {
            all: function(ring) {
                if (this[ring]) {
                    return this[ring].members;
                }
            }
        }
    };

    //
    // Packet regexes
    //
    var Patterns = {
        body: /::(.+)?/,
        domain: /\[(.*?)\]/,
        ring: /{(.*?)}/,
        zone: /\((.*?)\)/,
    };

    //
    // Moongate instance
    //
    exports.__proto__.init = function(params) {
        var params = params || {};

        this['__🔮__'] = null;
        this.ws = null;
        this.callbacks = params.callbacks || {};
        this.operations = params.operations || {};
        this.rings = {};
        this.state = params.state || {};
        this.zones = {};
        this.connect();
    }

    //
    // HTTP
    //
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

    //
    // WebSockets
    //
    exports.__proto__.connect = function() {
        this.request('GET', 'handshake', function(e) {
            var handshake = JSON.parse(e.target.response);

            this['__🔮__'] = handshake.version;
            this.rings = handshake.rings;
            this.loop(handshake.operations || {}, Core.registerOperation.bind(this));
            this.ws = new WebSocket('ws://' + handshake.ip + ':' + handshake.port + '/ws');
            this.ws.onopen = Behavior.ws.onopen.bind(this);
            this.ws.onmessage = Behavior.ws.onmessage.bind(this);
            this.ws.onclose = Behavior.ws.onclose.bind(this);
        }.bind(this));
    }
    exports.__proto__.send = function(string) {
        this.ws.send(string);
    }
    exports.__proto__.operation = function(key) {
        for (var prop in this.operations) {
            if (this.operations.hasOwnProperty(prop)) {
                if (this.operations[prop] === key) {
                    return Core.decimalToHex(prop);
                }
            }
        }
        return '00';
    }
    exports.__proto__.readPacket = function(packet) {
        return {
            body: Core.splitPacketChunk(packet, 'body'),
            domain: Core.matchPacketChunk(packet, 'domain'),
            ring: Core.matchPacketChunk(packet, 'ring'),
            zone: Core.matchPacketChunk(packet, 'zone')
        }
    }
    exports.__proto__.writePacket = function(payload) {
        return (
            '#' +
            Core.wrapPacketChunk(payload.domain, '[', ']') +
            Core.wrapPacketChunk(payload.zone, '(', ')') +
            Core.wrapPacketChunk(payload.ring, '{', '}') +
            Core.wrapPacketChunk(payload.deed, '<', '>') +
            Core.preparePacketBody(payload.body, '::')
        );
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

    //
    // State
    //
    exports.__proto__.addRing = function(packet) {
        var ring = this.rings[packet.ring[0]],
            zone = this.zone(packet.zone[0], packet.zone[1]),
            result;

        if (ring && zone) {
            result = JSON.parse(packet.body);
            result.__proto__.__index = packet.ring[1];

            zone[packet.ring[0]].members[packet.ring[1]] = result;

            return result;
        }
        return false;
    }
    exports.__proto__.joinRing = function(packet) {
        Core.touchRing.call(this, packet);
    }
    exports.__proto__.joinZone = function(packet) {
        Core.touchZone.call(this, packet);
    }
    exports.__proto__.removeRing = function(packet) {
        var ring = this.rings[packet.ring[0]],
            zone = this.zone(packet.zone[0], packet.zone[1]);

        if (ring && zone && zone[packet.ring[0]].members[packet.ring[1]]) {
            zone[packet.ring[0]].members[packet.ring[1]] = null;
            delete zone[packet.ring[0]].members[packet.ring[1]];

            return true;
        }
        return false;
    }
    exports.__proto__.setRing = function(packet) {
        var ring = this.rings[packet.ring[0]],
            zone = this.zone(packet.zone[0], packet.zone[1]),
            body = JSON.parse(packet.body);

        if (ring && zone && zone[packet.ring[0]].members[packet.ring[1]]) {
            zone[packet.ring[0]].members[packet.ring[1]] = (
                Core.extend(zone[packet.ring[0]].members[packet.ring[1]], body)
            );
            return zone[packet.ring[0]].members[packet.ring[1]];
        }
        return false;
    }
    exports.__proto__.stateOperation = function(packet) {
        this.state = Core.extend(this.state, JSON.parse(packet.body));
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

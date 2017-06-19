(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory();
	else if(typeof define === 'function' && define.amd)
		define("Moongate", [], factory);
	else if(typeof exports === 'object')
		exports["Moongate"] = factory();
	else
		root["Moongate"] = factory();
})(this, function() {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__(1);


/***/ }),
/* 1 */
/***/ (function(module, exports, __webpack_require__) {

	"use strict";
	var Atlas_1 = __webpack_require__(2);
	var Session_1 = __webpack_require__(5);
	var Socket_1 = __webpack_require__(14);
	var Utility_1 = __webpack_require__(7);
	var Client = (function () {
	    function Client(config) {
	        this.Utility = Utility_1.Utility;
	        this.config = config || {};
	        this.atlas = new Atlas_1.Atlas(this);
	        this.session = new Session_1.Session(this);
	        return this;
	    }
	    Client.prototype.init = function () {
	        this.socket = new Socket_1.Socket(this);
	        if (this.config.onConnect) {
	            this.config.onConnect.apply(this);
	        }
	        return true;
	    };
	    Client.prototype.send = function (packet) {
	        return this.socket.send(packet);
	    };
	    return Client;
	}());
	exports.Client = Client;


/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

	"use strict";
	var Environment_1 = __webpack_require__(3);
	var HTTPRequest_1 = __webpack_require__(4);
	var Atlas = (function () {
	    function Atlas(context) {
	        this._ = context;
	        this.fetch(context.init.bind(context), context.config);
	    }
	    Atlas.prototype.endpoint = function (config) {
	        if (config.socketAddress) {
	            return config.socketAddress;
	        }
	        else {
	            var hostname = config.origin || Environment_1.Environment.localHostname(), port = config.port || Environment_1.Environment.localPort(), protocol = config.port || Environment_1.Environment.localProtocol();
	            return protocol + "//" + hostname + ":" + port + "/atlas";
	        }
	    };
	    Atlas.prototype.fetch = function (callback, config) {
	        return HTTPRequest_1.HTTPRequest.fetch(this.endpoint(config), 'json', this.done.bind(this, callback));
	    };
	    Atlas.prototype.done = function (callback, response) {
	        this.ip = response.ip;
	        this.packet = response.packet;
	        this.port = response.port;
	        this.rings = response.rings;
	        this.version = response.version;
	        this.zones = response.zones;
	        callback();
	    };
	    return Atlas;
	}());
	exports.Atlas = Atlas;


/***/ }),
/* 3 */
/***/ (function(module, exports) {

	"use strict";
	var Environment = (function () {
	    function Environment() {
	    }
	    // Executes one of two callbacks depending on the execution
	    // environment. If Moongate is running in a web browser, the
	    // first callback is called. If Moongate is running in Node.js,
	    // the second callback is called. An exception is thrown if
	    // the execution callback is not one of these two.
	    Environment.callByContext = function (browserCallback, nodeCallback) {
	        switch (Environment.context()) {
	            case 'browser':
	                return browserCallback();
	            case 'node':
	                return nodeCallback();
	            default:
	                throw Environment.contextError();
	        }
	    };
	    Environment.context = function () {
	        var isBrowser = new Function('try { return this === window; } catch(e) { return false; }'), isNode = new Function('try { return this === global; } catch(e) { return false; }');
	        if (isBrowser()) {
	            return 'browser';
	        }
	        else if (isNode()) {
	            return 'node';
	        }
	        return 'unknown;';
	    };
	    Environment.contextError = function () {
	        return 'Unknown Executation Context';
	    };
	    Environment.localHostname = function () {
	        return Environment.callByContext(function () { return window.location.hostname; }, function () { return ''; });
	    };
	    Environment.localPort = function () {
	        return Environment.callByContext(function () { return window.location.port; }, function () { return ''; });
	    };
	    Environment.localProtocol = function () {
	        return Environment.callByContext(function () { return window.location.protocol; }, function () { return ''; });
	    };
	    Environment.viewport = function () {
	        return {
	            width: window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth,
	            height: window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight
	        };
	    };
	    return Environment;
	}());
	exports.Environment = Environment;


/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {

	"use strict";
	var Environment_1 = __webpack_require__(3);
	var HTTPRequest = (function () {
	    function HTTPRequest() {
	    }
	    HTTPRequest.fetch = function (url, type, callback) {
	        Environment_1.Environment.callByContext(function () {
	            var req = new XMLHttpRequest();
	            req.onreadystatechange = function () {
	                if (this.readyState === 4 && this.status === 200) {
	                    switch (type) {
	                        case 'json':
	                            return callback(JSON.parse(this.response));
	                        default:
	                            return callback(this.response);
	                    }
	                }
	            };
	            req.open('GET', url, true);
	            req.send();
	        }, function () { });
	        return true;
	    };
	    return HTTPRequest;
	}());
	exports.HTTPRequest = HTTPRequest;


/***/ }),
/* 5 */
/***/ (function(module, exports, __webpack_require__) {

	"use strict";
	var EventHandler_1 = __webpack_require__(6);
	var GameLoop_1 = __webpack_require__(10);
	var Zone_1 = __webpack_require__(11);
	var Session = (function () {
	    function Session(context) {
	        this._ = context;
	        this.attached = {};
	        this.loop = new GameLoop_1.Loop(this);
	        this.handler = new EventHandler_1.Handler(this._.config);
	        this.zones = {};
	    }
	    Session.prototype.handle = function (packet) {
	        this.handler.callback(packet.handler, packet, this);
	    };
	    Session.prototype.destroyMembers = function (memberIndices, zone, zoneName, ring) {
	        if (!this.zones[zone]) {
	            return [];
	        }
	        if (!this.zones[zone][zoneName]) {
	            return [];
	        }
	        if (!this.zones[zone][zoneName].rings[ring]) {
	            return [];
	        }
	        this.zones[zone][zoneName].rings[ring].destroyMembers(memberIndices);
	        return {
	            indices: memberIndices,
	            ring: ring
	        };
	    };
	    Session.prototype.destroyZone = function (zone, zoneName) {
	        if (!this.zones[zone]) {
	            return false;
	        }
	        if (!this.zones[zone][zoneName]) {
	            return false;
	        }
	        delete this.zones[zone][zoneName];
	        return true;
	    };
	    Session.prototype.upsertMembers = function (members, zone, zoneName, ring) {
	        this.upsertRing(zone, zoneName, ring);
	        return this.zones[zone][zoneName].rings[ring].upsertMembers(members);
	    };
	    Session.prototype.upsertMorphs = function (morphs, zone, zoneName, ring) {
	        this.upsertRing(zone, zoneName, ring);
	        return this.zones[zone][zoneName].rings[ring].upsertMorphs(morphs);
	    };
	    Session.prototype.upsertZone = function (zone, zoneName) {
	        if (!this.zones[zone]) {
	            this.zones[zone] = {};
	        }
	        if (!this.zones[zone][zoneName]) {
	            this.zones[zone][zoneName] = new Zone_1.Zone();
	        }
	        return this.zones[zone][zoneName];
	    };
	    Session.prototype.upsertRing = function (zone, zoneName, ring) {
	        this.upsertZone(zone, zoneName);
	        if (!this.zones[zone][zoneName].rings[ring]) {
	            this.zones[zone][zoneName].addRing(ring, this._.atlas.rings[ring] || {});
	            return this.zones[zone][zoneName].rings[ring];
	        }
	    };
	    return Session;
	}());
	exports.Session = Session;


/***/ }),
/* 6 */
/***/ (function(module, exports, __webpack_require__) {

	"use strict";
	var Utility_1 = __webpack_require__(7);
	var Events_1 = __webpack_require__(8);
	var Handler = (function () {
	    function Handler(config) {
	        this.callbacks = Events_1.default;
	        this.clientCallbacks = config.callbacks || {};
	    }
	    Handler.prototype.callback = function (callbackKey, packet, session) {
	        var key = Utility_1.Utility.camelize(callbackKey);
	        if (this.callbacks[key] && this.callbacks[key] instanceof Function) {
	            var result = this.callbacks[key].call(this, packet, session);
	            if (this.clientCallbacks[key] && this.clientCallbacks[key] instanceof Function) {
	                return this.clientCallbacks[key].apply(this, [result]);
	            }
	            return result;
	        }
	        return null;
	    };
	    Handler.prototype.clientCallback = function (key, args, session) {
	        if (this.clientCallbacks[key] && this.clientCallbacks[key] instanceof Function) {
	            return this.clientCallbacks[key].apply(this, args.concat(session));
	        }
	        return null;
	    };
	    return Handler;
	}());
	exports.Handler = Handler;


/***/ }),
/* 7 */
/***/ (function(module, exports) {

	"use strict";
	var htmlEntities = {
	    '&': '&amp;',
	    '<': '&lt;',
	    '>': '&gt;',
	    '"': '&quot;',
	    '\'': '&#39;',
	    '/': '&#x2F;',
	    '`': '&#x60;',
	    '=': '&#x3D;'
	};
	var Utility = (function () {
	    function Utility() {
	    }
	    Utility.camelize = function (input) {
	        return input.replace(/(\_\w)/g, function (m) { return m[1].toUpperCase(); });
	    };
	    Utility.capitalize = function (input) {
	        return input.charAt(0).toUpperCase() + input.slice(1);
	    };
	    Utility.escapeHtml = function (input) {
	        return String(input).replace(/[&<>"'`=\/]/g, function (chunk) {
	            return htmlEntities[chunk];
	        });
	    };
	    Utility.numberToHex = function (number, padding) {
	        return (number + Math.pow(16, padding)).toString(16).slice(-padding).toUpperCase();
	    };
	    return Utility;
	}());
	exports.Utility = Utility;


/***/ }),
/* 8 */
/***/ (function(module, exports, __webpack_require__) {

	"use strict";
	var Packets_1 = __webpack_require__(9);
	Object.defineProperty(exports, "__esModule", { value: true });
	exports.default = {
	    attach: function (packet, session) {
	        var _a = Packets_1.Packets.decodePair(packet.body), key = _a[0], value = _a[1];
	        session.attached[key] = value;
	        return value;
	    },
	    command: function (packet, session) {
	        var _a = Packets_1.Packets.decodePair(packet.body), callbackKey = _a[0], args = _a[1];
	        return session.handler.clientCallback(callbackKey, JSON.parse(args), session);
	    },
	    dropMembers: function (packet, session) {
	        var results = Packets_1.Packets.decodeList(packet.body).map(Packets_1.Packets.decodeInt), _a = packet.zone, zone = _a[0], zoneName = _a[1];
	        return session.destroyMembers(results, zone, zoneName, packet.ring);
	    },
	    echo: function (packet, session) {
	        console.log("\uD83D\uDD2E " + packet.body);
	        return packet.body;
	    },
	    leave: function (packet, session) {
	        var _a = packet.zone, zone = _a[0], zoneName = _a[1];
	        return session.destroyZone(zone, zoneName);
	    },
	    join: function (packet, session) {
	        var _a = packet.zone, zone = _a[0], zoneName = _a[1];
	        return session.upsertZone(zone, zoneName);
	    },
	    ping: function (packet, session) {
	        var ping = new Date().getTime() - Packets_1.Packets.decodeInt(packet.body);
	        session.ping = ping;
	        return session.ping;
	    },
	    indexMembers: function (packet, session) {
	        var _a = packet.zone, zone = _a[0], zoneName = _a[1], ring = packet.ring;
	        if (session._.atlas.rings[ring]) {
	            var schema = session._.atlas.rings[ring], schemaKeys = Object.keys(schema), results = Packets_1.Packets.decompressMap(packet.body, schemaKeys);
	            session.upsertZone(zone, zoneName);
	            return session.upsertMembers(results, zone, zoneName, ring);
	        }
	        return null;
	    },
	    showMembers: function (packet, session) {
	        var _a = packet.zone, zone = _a[0], zoneName = _a[1], chunks = packet.body.split(/:(.+)/), ring = packet.ring;
	        if (session.zones[zone] && session.zones[zone][zoneName] && session.zones[zone][zoneName].rings[ring]) {
	            var schema = Packets_1.Packets.decompressSchemaKeys(chunks[0], session._.atlas.packet.compressor), results = Packets_1.Packets.decompressMap(chunks[1], schema);
	            return session.upsertMembers(results, zone, zoneName, ring);
	        }
	        return null;
	    },
	    showMorphs: function (packet, session) {
	        var results = Packets_1.Packets.decompressMorphs(packet.body, session._.atlas.packet.compressor), _a = packet.zone, zone = _a[0], zoneName = _a[1];
	        return session.upsertMorphs(results, zone, zoneName, packet.ring);
	    }
	};


/***/ }),
/* 9 */
/***/ (function(module, exports) {

	"use strict";
	var Packets = (function () {
	    function Packets() {
	    }
	    Packets.decode = function (packet, packetCompressor) {
	        return Packets.decompressPacket({
	            body: Packets.splitChunk(packet, 'body'),
	            handler: Packets.matchChunk(packet, 'handler'),
	            raw: packet,
	            ring: Packets.matchChunk(packet, 'ring'),
	            rule: Packets.matchChunk(packet, 'rule'),
	            zone: Packets.matchChunk(packet, 'zone')
	        }, packetCompressor);
	    };
	    Packets.encode = function (packet, packetCompressor) {
	        return ('#' +
	            Packets.encodeChunk(packet.handler, '[', ']', packetCompressor) +
	            Packets.encodeChunk(packet.zone, '(', ')', packetCompressor) +
	            Packets.encodeChunk(packet.ring, '{', '}', packetCompressor) +
	            Packets.encodeChunk(packet.rule, '<', '>', packetCompressor) +
	            Packets.encodeBody(packet.body));
	    };
	    Packets.matchChunk = function (packet, key) {
	        var match = packet.match(Packets.patterns()[key]);
	        if (match && match[0]) {
	            var parts = match[1].split(':');
	            if (parts.length === 1) {
	                return parts[0];
	            }
	            return parts;
	        }
	        return null;
	    };
	    Packets.patterns = function () {
	        return {
	            body: /::(.+)?/,
	            handler: /\[(.*?)\]/,
	            ring: /{(.*?)}/,
	            rule: /<(.*?)>/,
	            zone: /\((.*?)\)/
	        };
	    };
	    Packets.compressChunk = function (chunk, packetCompressor) {
	        return packetCompressor.by_word[chunk] || chunk;
	    };
	    Packets.encodeBody = function (body) {
	        if (body) {
	            if (body instanceof Array) {
	                return "::" + body.join('|');
	            }
	            else if (body instanceof Object) {
	                return "::" + JSON.stringify(body);
	            }
	            return "::" + body;
	        }
	        return '';
	    };
	    Packets.encodeChunk = function (chunk, left, right, packetCompressor) {
	        if (chunk instanceof Array) {
	            return Packets.wrapChunk(chunk.map(function (c) {
	                return Packets.compressChunk(c, packetCompressor);
	            }), left, right);
	        }
	        else if (chunk) {
	            return Packets.wrapChunk(Packets.compressChunk(chunk, packetCompressor), left, right);
	        }
	        return '';
	    };
	    Packets.splitChunk = function (chunk, patternKey) {
	        var match = chunk.split(Packets.patterns()[patternKey]);
	        return match.slice(1).join('');
	    };
	    Packets.wrapChunk = function (chunk, left, right) {
	        if (chunk instanceof Array) {
	            return "" + left + chunk.join(':') + right;
	        }
	        return "" + left + chunk + right;
	    };
	    Packets.decodeInt = function (string) {
	        return parseInt(string, 10);
	    };
	    Packets.decodeList = function (string) {
	        return string.split(',');
	    };
	    Packets.decodePair = function (string) {
	        return string.split(/:(.+)/).slice(0, 2);
	    };
	    Packets.decompressPacket = function (packet, packetCompressor) {
	        return {
	            body: packet.body,
	            handler: Packets.decompressField(packet.handler, packetCompressor),
	            ring: Packets.decompressField(packet.ring, packetCompressor),
	            rule: Packets.decompressField(packet.rule, packetCompressor),
	            zone: Packets.decompressZone(packet.zone, packetCompressor)
	        };
	    };
	    Packets.decompressField = function (field, packetCompressor) {
	        return packetCompressor.by_token[field] || field;
	    };
	    Packets.decompressZone = function (zoneField, packetCompressor) {
	        if (zoneField instanceof Array && zoneField.length == 2) {
	            return [
	                Packets.decompressField(zoneField[0], packetCompressor),
	                zoneField[1]
	            ];
	        }
	        else if (zoneField) {
	            return Packets.decompressField(zoneField, packetCompressor);
	        }
	        return null;
	    };
	    Packets.decompressSchemaKeys = function (schemaString, packetCompressor) {
	        return schemaString.split('|').map(function (token) { return packetCompressor.by_token[token]; });
	    };
	    Packets.decompressMap = function (mapString, schemaKeys) {
	        var chunks = mapString.split('&'), keys = schemaKeys.sort(), members = chunks.map(function (chunk) { return chunk.split('|'); }), results = [];
	        for (var i = 0, l = chunks.length; i !== l; i++) {
	            var result = {};
	            for (var j = 0, k = keys.length; j !== k; j++) {
	                result[keys[j]] = members[i][j];
	            }
	            results.push(result);
	        }
	        return results;
	    };
	    Packets.decompressMorphs = function (body, packetCompressor) {
	        var results = (body.split('&')
	            .map(function (chunk) { return chunk.split(':'); })
	            .map(function (chunk) {
	            var selector = chunk[0], tweenChunk = chunk[1], _a = selector.split('|'), rule = _a[0], key = _a[1], index = _a[2], tween = Packets.decompressTween(tweenChunk);
	            if (tween) {
	                return {
	                    index: parseInt(index, 10),
	                    rule: packetCompressor.by_token[rule],
	                    tween: tween,
	                    key: packetCompressor.by_token[key]
	                };
	            }
	        })
	            .filter(function (result) { return !!result; }));
	        return results;
	    };
	    Packets.decompressTween = function (body) {
	        var result = body.match(/(?:~([0-9]+)[d]([-+]?[0-9]+)~([0-9]+))/);
	        if (result && result[1] && result[2] && result[3]) {
	            return {
	                startedAt: parseInt(result[1], 10),
	                amount: parseInt(result[2], 10),
	                interval: parseInt(result[3], 10)
	            };
	        }
	        return null;
	    };
	    Packets.isKeyValue = function (body) {
	        return false;
	    };
	    return Packets;
	}());
	exports.Packets = Packets;


/***/ }),
/* 10 */
/***/ (function(module, exports, __webpack_require__) {

	"use strict";
	var Environment_1 = __webpack_require__(3);
	var Loop = (function () {
	    function Loop(context) {
	        var _this = this;
	        this._ = context;
	        this.queue = [];
	        Environment_1.Environment.callByContext(function () { _this.browserLoop(); }, function () { _this.nodeLoop(); });
	    }
	    Loop.prototype.browserLoop = function () {
	        if (this.queue.length === 0) {
	            return window.requestAnimationFrame(this.browserLoop.bind(this));
	        }
	        return window.requestAnimationFrame(this.browserLoop.bind(this));
	    };
	    Loop.prototype.nodeLoop = function () {
	    };
	    Loop.prototype.push = function (element) {
	        this.queue.push(element);
	    };
	    return Loop;
	}());
	exports.Loop = Loop;


/***/ }),
/* 11 */
/***/ (function(module, exports, __webpack_require__) {

	"use strict";
	var Ring_1 = __webpack_require__(12);
	var Zone = (function () {
	    function Zone() {
	        this.rings = {};
	    }
	    Zone.prototype.addRing = function (name, schema) {
	        this.rings[name] = new Ring_1.Ring(name, schema);
	    };
	    return Zone;
	}());
	exports.Zone = Zone;


/***/ }),
/* 12 */
/***/ (function(module, exports, __webpack_require__) {

	"use strict";
	var RingMember_1 = __webpack_require__(13);
	var Ring = (function () {
	    function Ring(name, schema) {
	        this.indices = [];
	        this.members = [];
	        this.morphs = {};
	        this.name = name;
	        this.schema = schema;
	    }
	    Ring.prototype.refreshIndices = function () {
	        var result = [];
	        for (var i = 0, l = this.members.length; i !== l; i++) {
	            result.push(this.members[i].index());
	        }
	        this.indices = result;
	    };
	    Ring.prototype.destroyMembers = function (memberIndices) {
	        this.members = this.members.filter(function (member) {
	            return memberIndices.indexOf(member.index()) == -1;
	        });
	        this.refreshIndices();
	        return memberIndices;
	    };
	    Ring.prototype.upsertMembers = function (membersParams) {
	        var _this = this;
	        return membersParams.map(function (memberParams) { return _this.upsertMember(memberParams); });
	    };
	    Ring.prototype.upsertMember = function (memberParams) {
	        var index = parseInt(memberParams.__index__, 10), memberIndex = this.indices.indexOf(index);
	        if (memberIndex > -1) {
	            return this.updateMember(memberIndex, memberParams);
	        }
	        return this.insertMember(memberParams);
	    };
	    Ring.prototype.upsertMorphs = function (morphs) {
	        var _this = this;
	        return morphs.map(function (morph) { return _this.upsertMorph(morph); });
	    };
	    Ring.prototype.upsertMorph = function (morph) {
	        if (!this.morphs[morph.rule]) {
	            this.morphs[morph.rule] = {};
	        }
	        if (!this.morphs[morph.rule][morph.key]) {
	            this.morphs[morph.rule][morph.key] = {
	                morphs: {}
	            };
	        }
	        this.morphs[morph.rule][morph.key].morphs[morph.index] = morph.tween;
	    };
	    Ring.prototype.updateMember = function (memberIndex, params) {
	        var _this = this;
	        var member = this.members[memberIndex];
	        Object.keys(this.schema).forEach(function (key) {
	            if (params[key]) {
	                member.setAttribute(key, Ring.castMemberValue(params[key], _this.schema[key]));
	            }
	        });
	        this.refreshIndices();
	        return member;
	    };
	    Ring.prototype.insertMember = function (params) {
	        var _this = this;
	        var result = {};
	        Object.keys(this.schema).forEach(function (key) {
	            if (params[key]) {
	                result[key] = Ring.castMemberValue(params[key], _this.schema[key]);
	            }
	        });
	        var member = new RingMember_1.RingMember(result, this);
	        this.members.push(member);
	        this.refreshIndices();
	        return member;
	    };
	    Ring.castMemberValue = function (value, type) {
	        switch (type) {
	            case 'Integer':
	                return parseInt(value, 10);
	            case 'Morphs':
	                return JSON.parse(value);
	            default:
	                return value;
	        }
	    };
	    return Ring;
	}());
	exports.Ring = Ring;


/***/ }),
/* 13 */
/***/ (function(module, exports) {

	"use strict";
	var RingMember = (function () {
	    function RingMember(attributes, context) {
	        this._ = context;
	        this.attributes = attributes;
	        this.isNew = true;
	    }
	    RingMember.prototype.index = function () {
	        return this.attributes.__index__;
	    };
	    RingMember.prototype.setAttribute = function (key, value) {
	        this.attributes[key] = value;
	        this.isNew = false;
	    };
	    RingMember.prototype.morphed = function () {
	        var index = this.index(), result = this.attributes, keys = Object.keys(this.attributes), now = new Date();
	        for (var i = 0, l = keys.length; i !== l; i++) {
	            var ruleKeys = Object.keys(this._.morphs);
	            for (var j = 0, k = ruleKeys.length; j !== k; j++) {
	                var morph = this._.morphs[ruleKeys[j]];
	                if (morph[keys[i]] && morph[keys[i]].morphs && morph[keys[i]].morphs[index]) {
	                    var memberMorph = morph[keys[i]].morphs[index], delta = (now.getTime() - memberMorph.startedAt) * memberMorph.amount / memberMorph.interval;
	                    result[keys[i]] = result[keys[i]] + delta;
	                }
	            }
	        }
	        return result;
	    };
	    return RingMember;
	}());
	exports.RingMember = RingMember;


/***/ }),
/* 14 */
/***/ (function(module, exports, __webpack_require__) {

	"use strict";
	var Environment_1 = __webpack_require__(3);
	var Packets_1 = __webpack_require__(9);
	var Socket = (function () {
	    function Socket(context) {
	        this._ = context;
	        this.packetCompressor = context.atlas.packet.compressor;
	        this.connect();
	    }
	    Socket.prototype.connect = function () {
	        var _this = this;
	        Environment_1.Environment.callByContext(function () {
	            _this.protocol = 'ws';
	            _this.ws = new WebSocket('ws://' + _this._.atlas.ip + ':' + _this._.atlas.port + '/ws');
	            _this.ws.onopen = _this.onWsOpen.bind(_this);
	            _this.ws.onmessage = _this.onWsMessage.bind(_this);
	            _this.ws.onclose = _this.onWsClose.bind(_this);
	        }, function () { });
	    };
	    Socket.prototype.onWsOpen = function () {
	        this.send({
	            handler: 'begin'
	        });
	    };
	    Socket.prototype.onWsMessage = function (message) {
	        this._.session.handle(Packets_1.Packets.decode(message.data, this.packetCompressor));
	    };
	    Socket.prototype.onWsClose = function () {
	    };
	    Socket.prototype.send = function (packet) {
	        if (this.protocol === 'ws') {
	            this.ws.send(Packets_1.Packets.encode(packet, this.packetCompressor));
	        }
	    };
	    return Socket;
	}());
	exports.Socket = Socket;


/***/ })
/******/ ])
});
;
//# sourceMappingURL=Moongate.js.map
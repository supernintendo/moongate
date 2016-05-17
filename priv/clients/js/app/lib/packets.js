let Utils = require('./utils');

class Packets {
    constructor() {
    }

    static byteSize(str) {
        return encodeURIComponent(str).replace(/%[A-F\d]{2}/g, 'U').length;
    }

    static kv(string) {
        return string.split('¦ ').reduce((acc, pair) => {
            let [key, value] = pair.split(':¦');

            acc[key] = value;
            return acc;
        }, {});
    }

    // Return an object literal containing the parts of a raw packet.
    static parse(parts, extras) {
        let [time, target, action, ...params] = parts,
            [namespace, ...idParts] = target.split('_'),
            id = idParts.join('_');

        return Object.assign({
            action: action,
            id: id,
            latency: Date.now() - time,
            from: namespace,
            params: params
        }, extras);
    }

    // Prepare a packet to be sent to the server.
    static outgoing(delimiter, parts) {
        if (parts) {
            let packet = parts.join(delimiter),
                regex = new RegExp(delimiter, 'g'),
                length = packet.replace(regex, '').length;

            return `${length}{${packet}}`;
        }
    }

    static target(parts) {
        let scope = parts.split(' ').slice(0, 2),
            [poolName, stageName] = scope[0].split('__for__'),
            index = scope[1],
            stage = this.stages && this.stages[stageName],
            pool = poolName && stage && stage[poolName],
            result = {};

        if (index)
            result['index'] = Number(index);
        if (stage)
            result['stage'] = stage;
        if (pool)
            result['pool'] = pool;

        return result;
    }

    // Deconstruct a packet string to a packet array.
    static unravel(message) {
        let [length, contents] = message.split(/{(.*?)}/g),
            parts = contents.split('·');

        // Verify packet length
        if (Number(length) === this.byteSize(parts.join(''))) {
            return parts;
        }
        return [];
    }
}
export default Packets

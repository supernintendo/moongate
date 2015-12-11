class Packets {
    constructor() {
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
    static outgoing(packet) {
        let length = packet.replace(/\s/g, '').length;

        return `${length}{${packet}}`;
    }

    // Deconstruct a packet string to a packet array.
    static unravel(message) {
        let [length, contents] = message.split(/{(.*?)}/g),
            parts = contents.split('░');

        // Verify packet length
        if (Number(length) === parts.join('').length) {
            return parts;
        }
        return [];
    }
};

export default Packets;

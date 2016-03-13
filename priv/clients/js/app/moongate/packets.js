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
    static outgoing(delimiter, parts) {
        if (parts) {
            let packet = parts.join(delimiter),
                regex = new RegExp(delimiter, 'g'),
                length = packet.replace(regex, '').length;

            return `${length}{${packet}}`;
        }
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

    static byteSize(str) {
        var s = str.length;

        for (var i = str.length - 1; i >= 0; i--) {
            var code = str.charCodeAt(i);

            if (code > 0x7f && code <= 0x7ff) {
                s++;
            } else if (code > 0x7ff && code <= 0xffff) {
                s+=2;
            }
            if (code >= 0xDC00 && code <= 0xDFFF) {
                i--; //trail surrogate
            }
        }
        return s;
    }
}
export default Packets

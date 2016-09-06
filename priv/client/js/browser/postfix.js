// partial JS passed to emcc --pre-js flag
    console.log(
        '🔮 Welcome to %cMoongate%c v%c0.2.0.',
        'color: #C065DB',
        'color: #757178',
        'color: #009FCB'
    );

    return new Module.Moongate();
})();

Moongate['🔮'] = 'v0.2.0';
Moongate.handshake = {
    ip: null,
    sockets: {}
};
Moongate.Firmware = {
    connect() {
        if (Moongate.handshake.sockets.ws) {
            Moongate.WebSocket = new WebSocket(this.webSocketAddress());
            Moongate.WebSocket.onopen = this.connected.bind(this);
            Moongate.WebSocket.onmessage = this.receive.bind(this);
        };
    },
    connected() {
        Moongate.connected();
    },
    handshake(result) {
        Moongate.handshake = JSON.parse(result.target.response);
        this.connect();
    },
    receive(event) {
        console.log(event.data);
        Moongate.receive();
    },
    request(verb, address, callback) {
        var request = new XMLHttpRequest();

        request.addEventListener('load', callback.bind(this));
        request.open(verb, address);
        request.send();
    },
    up() {
        this.request('GET', '/handshake.json', this.handshake);
    },
    webSocketAddress() {
        return 'ws://' + Moongate.handshake.ip + ':' + Moongate.handshake.sockets.ws;
    }
};

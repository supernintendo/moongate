var App = {
    socket: new WebSocket('ws://127.0.0.1:2593'),
    stages: [],
    dim: function(id) {
        /* Darken a packet indicator.
         */
        document.getElementById(id + '-indicator').className = 'off';
    },
    flash: function(id) {
        /* Highlight a packet indicator.
         */
        document.getElementById(id + '-indicator').className = '';
        setTimeout(this.dim.bind(this, id), 400);
    },
    init: function() {
        /* Bind event listeners neccessary for this to do things,
         and show a random welcome message. */
        document.getElementById('send-packet').addEventListener('click', this.sendPacket.bind(this));
        document.getElementById('presets').addEventListener('change', this.setFromPreset.bind(this));
        this.socket.onmessage = this.receivePacket.bind(this);
    },
    handlePacket: function(packet) {
        /* Take a packet and if it is valid, do stuff with
         it. */
        var parsedPacket = packet.split(/{(.*?)}/),
            parts = parsedPacket[1].split(' ');

        if (this.isValidPacket(parsedPacket)) {
            if (this.isAuthPacket(parts)) { return; }
            if (this.isStagePacket(parts)) { return; }
        }
    },
    isAuthPacket: function(parts) {
        /* If the given packet is an auth packet, set the auth
         token input to the token in the packet. */
        if (parts[1].split('_')[0] === 'events' && parts[2] === 'set_token') {
            document.getElementById('auth-token').value = parts[3];
            return true;
        }
        return false;
    },
    isStagePacket: function(parts) {
        /* If the given packet is a stage packet, update the array
         of current stages as well as stage display. */
        var index = this.stages.indexOf(parts[1]);

        if (parts[2] === 'transaction') {
            if (parts[3] === 'join' && index === -1) {
                this.stages.push(parts[1]);
            } else if (parts[3] === 'leave' && index > -1) {
                this.stages.splice(index);
            }
            if (this.stages.length > 1) {
                document.getElementById('stage-prefix').innerHTML = 'Currently on stages: ';
                document.getElementById('stage-name').innerHTML = this.stages.join(', ') + '.';
            } else if (this.stages.length === 1) {
                document.getElementById('stage-prefix').innerHTML = 'Currently on stage ';
                document.getElementById('stage-name').innerHTML = this.stages[0] + '.';
            } else {
                document.getElementById('stage-prefix').innerHTML = 'Currently not on any stage.';
                document.getElementById('stage-name').innerHTML = '';
            }
            return true;
        }
        return false;
    },
    isValidPacket: function(message) {
        /* Make sure the packet length is correct.
         */
        return Number(message[0]) === message[1].replace(/\s/g, '').length;
    },
    sendPacket: function() {
        /* Prepare a fresh packet and send it to the server.
         */
        var token = document.getElementById('auth-token').value,
            message = document.getElementById('message').value,
            packet = token + ' ' + message,
            length = packet.replace(/\s/g, '').length;

        this.socket.send(length + '{' + packet + '}');
        this.flash('outgoing');
    },
    setFromPreset: function(e) {
        /* Change the value of the outgoing packet input to a
         selection in the preset dropdown. */
        document.getElementById('message').value = e.target.value;
        document.getElementById('presets')[0].selected = true;
    },
    receivePacket: function(e) {
        /* Receive a packet from the server.
         */
        var str = '<code>' + e.data + '</code>',
            div = document.createElement('div');

        div.className = 'snippet';
        div.innerHTML = str;
        document.getElementById('log').appendChild(div);
        setTimeout(function() {
            div.className = 'snippet expand';
        }, 100);
        document.getElementById('log').appendChild(document.createElement('br'));

        this.flash('incoming');
        this.handlePacket(e.data);
    }
};
App.init();

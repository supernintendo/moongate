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
        document.getElementById('auth-token').addEventListener('keyup', this.handleKeyUp.bind(this));
        document.getElementById('message').addEventListener('keyup', this.handleKeyUp.bind(this));
        this.socket.onclose = this.updateConnectionStatus.bind(this, 'off');
        this.socket.onopen = this.updateConnectionStatus.bind(this, 'on');
        this.socket.onmessage = this.receivePacket.bind(this);
    },
    handleKeyUp: function(e) {
        var key = e.keyCode || e.which;

        if (key === 13) {
            this.sendPacket();
        }
        this.updatePresetDisplay(e);
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
    },
    receivePacket: function(e) {
        /* Receive a packet from the server.
         */
        this.writeToConsole(e.data);
        this.flash('incoming');
        this.handlePacket(e.data);
    },
    updateConnectionStatus: function(status) {
        var el = document.getElementById('connection-status');
        el.className = status;
        document.getElementById('send-packet').disabled = (status === 'off');

        if (status === 'off') {
            this.writeToConsole('This session has expired. Refresh the page to reconnect.', 'special')
        }
    },
    writeToConsole: function(content, className) {
        var str = '<code>' + content + '</code>',
            div = document.createElement('div'),
            scroll;

        div.className = 'snippet ' + className;
        div.innerHTML = str;

        if (window.scrollY + window.innerHeight >= document.body.scrollHeight) {
            scroll = true;
        }
        document.getElementById('log').appendChild(div);
        setTimeout(function() {
            div.className = 'snippet expand ' + className;
        }, 100);
        document.getElementById('log').appendChild(document.createElement('br'));

        if (scroll) {
            window.scrollTo(0, document.body.scrollHeight);
        }
    },
    updatePresetDisplay: function(e) {
        var value = e.target.value,
            match = document.querySelectorAll('option[value="' + value +'"]');

        if (match.length > 0) {
            document.getElementById('presets').value = value;
        } else {
            document.getElementById('presets')[0].selected = true;
        }
    }
};
App.init();

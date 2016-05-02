let GamePackets = { 
    keyup: function(key, gate) {
        let command = ['Player', 'move'];

        if (gate.keysPressed(65)) {
            command.push('left');
        } else if (gate.keysPressed(68)) {
            command.push('right');
        } else {
            command.push('xreset');
        }
        if (gate.keysPressed(87)) {
            command.push('up');
        } else if (gate.keysPressed(83)) {
            command.push('down');
        } else {
            command.push('yreset');
        }
        return command;
    },
    keydown: function(key) {
        switch (key) {
        case 32: // space
            return ['Player', 'attack'];
        case 87: // up
            return ['Player', 'move', '_', 'up'];
        case 65: // left
            return ['Player', 'move', 'left', '_'];
        case 83: // down
            return ['Player', 'move', '_', 'down'];
        case 68: // right
            return ['Player', 'move', 'right', '_'];
        default:
            return null;
        }
    }
};

export default GamePackets;

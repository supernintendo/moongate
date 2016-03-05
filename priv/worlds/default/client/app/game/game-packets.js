let GamePackets = {
    keyup: function(key, gate) {
        switch (key) {
        case 87: // up
            if (!gate.keysAreDown(83)) {
                return ['Player', 'stop', -1, 0];
            }
        case 65: // left
            if (!gate.keysAreDown(68)) {
                return ['Player', 'stop', -1, 0];
            }
        case 83: // down
            if (!gate.keysAreDown(87)) {
                return ['Player', 'stop', 0, 1];
            }
        case 68: // right
            if (!gate.keysAreDown(65)) {
                return ['Player', 'stop', 1, 0];
            }
        default:
            return null;
        }
    },
    keydown: function(key) {
        switch (key) {
        case 32: // space
            return ['Player', 'attack'];
        case 87: // up
            return ['Player', 'move', 0, -1];
        case 65: // left
            return ['Player', 'move', -1, 0];
        case 83: // down
            return ['Player', 'move', 0, 1];
        case 68: // right
            return ['Player', 'move', 1, 0];
        default:
            return null;
        }
    }
};

export default GamePackets;

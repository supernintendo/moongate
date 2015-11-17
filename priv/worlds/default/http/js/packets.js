var GamePackets = {
    keyup: function(key) {
        switch (key) {
        case 87: // up
            if (!GameGate.keyIsDown(83)) {
                return 'stop 0 -1';
            }
        case 65: // left
            if (!GameGate.keyIsDown(68)) {
                return 'stop -1 0';
            }
        case 83: // down
            if (!GameGate.keyIsDown(87)) {
                return 'stop 0 1';
            }
        case 68: // right
            if (!GameGate.keyIsDown(65)) {
                return 'stop 1 0';
            }
        default:
            return null;
        }
    },
    keydown: function(key) {
        switch (key) {
        case 32: // space
            return 'attack';
        case 87: // up
            return 'move 0 -1';
        case 65: // left
            return 'move -1 0';
        case 83: // down
            return 'move 0 1';
        case 68: // right
            return 'move 1 0';
        default:
            return null;
        }
    }
};

var Game = {
    authenticated: function() {
        GameGate.stageSend('proceed');
    },
    keydown: function(e, key, first) {
        var packet;
        if (first) {
            packet = GamePackets.keydown(key);
            packet && GameGate.stageSend(packet);
        }
    },
    keyup: function(e, key) {
        var packet,
            keysDown = GameGate.state.keyboard.keysDown;

        if (keysDown.indexOf(87) === -1 &&
            keysDown.indexOf(65) === -1 &&
            keysDown.indexOf(83) === -1 &&
            keysDown.indexOf(68) === -1) {
            packet = 'stop 1 1';
        } else {
            packet = GamePackets.keyup(key);
        }
        packet && GameGate.stageSend(packet);
    },
    poolMemberAdded: function(member, index, pool) {
        var member = GameCanvas.addEntity(pool, index, member);
    },
    poolMemberRemoved: function(member, index, pool) {
        GameCanvas.removeEntity(pool, index, member);
    },
    stageJoined: function(stage) {},
    tick: function() {
        GameCanvas.tick();
    }
};

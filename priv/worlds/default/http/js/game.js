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
        var packet;
        packet = GamePackets.keyup(key);
        packet && GameGate.stageSend(packet);
    },
    poolMemberAdded: function(member, index, pool) {
        GameCanvas.addEntity(index, member);
    },
    poolMemberRemoved: function(member, index, pool) {
        GameCanvas.removeEntity(index, member);
    },
    stageJoined: function(stage) {},
    tick: function() {
        GameCanvas.tick();
    }
};

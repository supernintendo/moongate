const MEMBERS = [],
      Player = require('./player');

class Board {
    constructor() {}
    static add(member) {
        let player = new Player(member);

        MEMBERS.push([player, player.element()]);
        $('#board').append(MEMBERS[MEMBERS.length - 1][1]);
    }
    static update() {
        MEMBERS.forEach(([player, element]) => {
            $(element).css({
                left: player.member.x,
                top: player.member.y,
            });
        })
    }
}
export default Board

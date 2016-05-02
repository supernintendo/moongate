class Player {
    constructor(member) {
        this.member = member;
    }
    element() {
        return $('<div></div>').css({
            backgroundColor: 'blue',
            height: '8px',
            width: '8px',
            left: this.member.x,
            top: this.member.y,
            position: 'relative',
        });
    }
}
export default Player

class Board {
    constructor(selector) {
        $('*').attr('data-board', null);
        $(selector).attr('data-board', '');
        this.members = {};
    }
    draw(member, index) {
        if (!this.members[index]) {
            this.members[index] = {
                element: $(`<div class="rainbow" data-index="${index}">`).appendTo('[data-board]'),
                member: member
            };
        } else {
            this.refresh(index);
        }
    }
    erase(index) {
        this.members[index].element.remove();
        delete this.members[index];
    }
    refresh(index) {
        if (this.members[index] && this.members[index].element) {
            this.members[index].element.css({
                left: this.members[index].member.x,
                top: this.members[index].member.y
            });
        }
    }
}
export default Board

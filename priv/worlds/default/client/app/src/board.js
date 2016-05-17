class Board {
    constructor(selector) {
        $('*').attr('data-board', null);
        $(selector).attr('data-board', '');
        this.members = {};
    }
    draw(member, index) {
        if (!this.members[index]) {
            this.members[index] = {
                elements: this.elementsForNewMember(index),
                member: member
            };
        } else {
            this.refresh(index);
        }
    }
    elementsForNewMember(index) {
        let max = 4,
            count = max,
            results = [];

        while (count--) {
            let el = $(`<div class="rainbow-fast" data-index="${index}">`)
                    .appendTo('[data-board]')
                    .css({
                        transitionDuration: `${(400 / count) + 1000}ms`,
                        opacity: count / max
                    });

            results.push(el);
        }
        return results;
    }
    erase(index) {
        this.members[index].element.remove();
        delete this.members[index];
    }
    refresh(index) {
        if (this.members[index] && this.members[index].elements) {
            this.members[index].elements.forEach((member) => {
                let x = this.members[index].member.x,
                    y = this.members[index].member.y,
                    translate = `translate(${x}px, ${y}px)`;

                member.css({
                    transform: translate
                });
            });
        }
    }
}
export default Board

let Bindings = {
    pool: {
        create(member, index) {
            this.game.board.draw(member, index);
        },
        refresh(member, index) {
            this.game.board.draw(member, index);
        },
        remove(index) {
            this.game.board.erase(index);
        },
        update(member, index) {
            this.game.board.draw(member, index);
        }
    },
    authenticated() {
        this.send('proceed');
    },
    tick(game) {
        if (this.stages.testLevel && this.stages.testLevel.player) {
            Object.keys(this.stages.testLevel.player.members).forEach((index) => {
                game.board.refresh(index);
            })
        }
        if (game.state.mouseTimer > 0) {
            game.state.mouseTimer -= 1;
        }
    }
};
export default Bindings

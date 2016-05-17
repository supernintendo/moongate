let Bindings = {
    pool: {
        create(member, index) {
            this.app.board.draw(member, index);
        },
        refresh(member, index) {
            this.app.board.draw(member, index);
        },
        remove(index) {
            this.app.board.erase(index);
        },
        update(member, index) {
            this.app.board.draw(member, index);
        }
    },
    authenticated() {
        this.send('proceed');
    },
    tick(app) {
        let stage = this.stages['Level_🔮'];

        if (stage && stage.Player) {
            Object.keys(stage.Player.members).forEach((index) => {
                app.board.refresh(index);
            })
        }
        if (app.state.mouseTimer > 0) {
            app.state.mouseTimer -= 1;
            if (app.state.mouseTimer <= 0) {
                app.mouseMoved();
            }
        }
    }
};
export default Bindings

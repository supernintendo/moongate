const Stage = require('./stage'),
      Utils = require('./utils');

class Stages {
    constructor() {
    }
    static addStage(id) {
        let key = Utils.camelize(id);

        if (!this.stages[key]) {
            this.stages[key] = new Stage();
        }
    }
}
export default Stages;

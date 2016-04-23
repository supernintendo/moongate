const Stage = require('./stage'),
      Packets = require('./packets'),
      Utils = require('./utils');

class Stages {
    constructor() {
    }
    static addStage(id) {
        let key = Utils.camelize(id);

        if (!this[key]) {
            this[key] = new Stage();

            return this[key];
        }
    }
    static leave(id, parts) {
        let target = Packets.target.call(this, parts),
            stageNames = Object.keys(this.stages);

        stageNames.forEach((stageName) => {
            if (target.stage === this.stages[stageName]) {
                delete this.stages[stageName];

                this.log('stageLeave', stageName);
            }
        });
    }
    static join(id, parts) {
        let [stageName, ...poolNames] = parts.split(' '),
            stage = Stages.addStage.apply(this.stages, [stageName]);

        poolNames.forEach((poolName) => {
            Stage.addPool.apply(stage, [Utils.camelize(poolName)])
        });
        this.log('stageJoin', stageName);
    }
}
export default Stages

const Pool = require('./pool'),
      Utils = require('./utils');

class Stage {
    constructor() {
    }
    static addPool(id, schema) {
        let key = Utils.camelize(id);

        if (!this[key]) {
            this[key] = new Pool(schema);
        }
    }
}
export default Stage

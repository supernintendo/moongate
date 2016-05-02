const Pool = require('./pool'),
      Dummy = require('./dummy'),
      Utils = require('./utils');

class Stage {
    constructor() {
    }
    pool(name) {
        if (this[name] && this[name] instanceof Pool) {
            return this[name];
        }
        return new Dummy();
    }
    static addPool(id, schema) {
        let key = Utils.camelize(id);

        if (!this[key]) {
            this[key] = new Pool(key, schema);
        }
    }
}
export default Stage

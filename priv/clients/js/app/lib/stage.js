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
        if (!this[id]) {
            this[id] = new Pool(id, schema);
        }
    }
}
export default Stage

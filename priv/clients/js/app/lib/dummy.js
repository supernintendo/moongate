const Member = require('./member');

class Dummy {
    constructor() {
    }
    clone() {
        return new this.constructor();
    }
    all() {
        return [];
    }
    pool() {
        return this.clone();
    }
    stage() {
        return this.clone();
    }
}
export default Dummy

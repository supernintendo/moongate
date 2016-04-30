const Utils = require('./utils');

class Member {
    constructor(attributes) {
        this.assign(attributes);
    }
    assign(attributes) {
        Utils.deepExtend(this, attributes);
    }
}
export default Member

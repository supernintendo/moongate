const Utils = require('./utils');

class Member {
    constructor(attributes) {
        Utils.deepExtend(this, attributes);
    }
}
export default Member

const Member = require('./member'),
      Schema = require('./schema'),
      Utils = require('./utils');

class Pool {
    constructor(name, schema = {}) {
        this.members = {};
        this.transformations = [];
        this.setSchema(schema);
    }
    setSchema(schema) {
        this.schema = Schema.parse(schema);
    }
    update(index, attributes) {
        let member = Object.keys(attributes).reduce((acc, key) => {
            acc[key] = Pool.conform(attributes[key], this.schema[key]);

            return acc;
        }, {});

        this.members[index] = new Member(member);
    }
    static conform(value, type) {
        if (type instanceof Function) {
            return type(value.replace('¦', ''));
        }
    }
}
export default Pool

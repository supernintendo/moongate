const Member = require('./member'),
      Schema = require('./schema'),
      Utils = require('./utils');

class Pool {
    constructor(name, schema = {}) {
        this.members = {};
        this.transformations = {};
        this.setSchema(schema);
    }
    all() {
        return Object.keys(this.members).map((key) => {
            return this.members[key];
        });
    }
    get(index) {
        return this.members[index];
    }
    setSchema(schema) {
        this.schema = Schema.parse(schema);
    }
    remove(index) {
        this.members[index] = null;

        delete this.members[index];
    }
    update(index, attributes) {
        let member = Object.keys(attributes).reduce((acc, key) => {
            acc[key] = Pool.conform(attributes[key], this.schema[key]);

            return acc;
        }, {});

        if (!this.members[index]) {
            this.members[index] = new Member(member);
        } else {
            this.members[index].assign(member);
        }
    }
    static conform(value, type) {
        if (type instanceof Function) {
            return type(value.replace('¦', ''));
        }
    }
}
export default Pool

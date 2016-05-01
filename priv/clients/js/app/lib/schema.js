class Schema {
    constructor() {

    }
    static parse(schema) {
        var parsed = {};

        Object.keys(schema).forEach((key) => {
            parsed[key] = Schema.parsedValue(schema[key]);
        });
        return parsed;
    }
    static parsedValue(value) {
        switch (value) {
        case 'float': return Number;
        case 'string': return String;
        default: return String;
        }
    }
}
export default Schema

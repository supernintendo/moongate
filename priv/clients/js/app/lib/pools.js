const Packets = require('./packets'),
      Stage = require('./stage'),
      Utils = require('./utils');

class Pools {
    constructor() {
    }
    /*
     Parses a schema string from a subscribe packet which contains
     information about what types of properties members of this
     pool may contain. An example of a string passed to this
     function might be:

     name:string x:float y:float origin:origin

     Here, each property is delimited by a ' '. Key name and
     type are delimited by ':'.
     */
    static parseSchema(pairs) {
        let l = pairs.length,
            results = {};

        while (l--) {
            let [key, value] = pairs[l].split(':');

            if (key && value) {
                results[key] = value;
            }
        }
        return results;
    }
    static memberCreated(id, parts) {
        let attributes = Packets.kv(parts.split(' ').slice(2).join(' ')),
            target = Packets.target.call(this, parts);

        if (target.pool) {
            target.pool.update(target.index, attributes);
        }
    }
    static subscribe(id, parts) {
        let [stageNameAndPoolName, ...attributes] = parts.split(' '),
            [stageName, poolName] = stageNameAndPoolName.split('__'),
            schema = Pools.parseSchema(attributes),
            stage = this.stages[Utils.camelize(stageName)];

        if (stage) {
            if (stage[Utils.camelize(poolName)]) {
                stage[Utils.camelize(poolName)].setSchema(schema);
            } else {
                Stage.addPool.apply(stage, [Utils.camelize(poolName), schema]);
            }
        }
    }
}
export default Pools

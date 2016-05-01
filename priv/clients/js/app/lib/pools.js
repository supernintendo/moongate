const Packets = require('./packets'),
      Pool = require('./pool'),
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
    static create(parts) {
        return Pools.poolUpdate.apply(this, arguments);
    }
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
    static remove(parts) {
        let target = Packets.target.call(this, parts);

        if (target.pool) {
            target.pool.remove(target.index);
        }
    }
    static poolUpdate(parts) {
        let attributes = Packets.kv(parts.split(' ').slice(2).join(' ')),
            target = Packets.target.call(this, parts);

        if (target.pool) {
            target.pool.update(target.index, attributes);
        }
        return target.pool.get(target.index);
    }
    static refresh(parts) {
        return Pools.poolUpdate.apply(this, arguments);
    }
    static subscribe(parts) {
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
        return stage;
    }
    static transform(parts) {
        let target = Packets.target.call(this, parts),
            [transform, key, delta] = parts.split(' ').slice(2),
            [type, tag] = transform.split(':');

        if (!target.pool.transformations[key]) {
            target.pool.transformations[key] = {};
        }
        if (!target.pool.transformations[key][target.index]) {
            target.pool.transformations[key][target.index] = {};
        }
        target.pool.transformations[key][target.index][tag] = [
            type,
            Pool.conform(delta, target.pool.schema[key])
        ];
    }
}
export default Pools

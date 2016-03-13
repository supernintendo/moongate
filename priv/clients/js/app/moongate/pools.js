class Pools {
    constructor() {
    }
    /*
     Parses a describe packet which contains information about
     what types of properties members of this pool may contain.
     An example of a string passed to this function might be:

     name:string¦x:float¦y:float¦origin:origin¦

     Here, each property is delimited by a '¦'. Key name and
     type are delimited by ':'.
     */
    static parseDescribe(parts) {
        let pairs = parts.split('¦'),
            l = pairs.length,
            results = {};

        while (l--) {
            let [key, value] = pairs[l].split(':');

            if (key && value) {
                results[key] = value;
            }
        }
        return results;
    }
}
export default Pools

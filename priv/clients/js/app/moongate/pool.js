class Pool {
    constructor() {
        this.members = {};
    }

    // Default attributes for a pool member.
    defaultMember() {
        return {
            new: true,
            values: {}
        };
    }

    /*
     A describe packet contains information about what types of
     properties members of this pool may contain. An example of
     a string passed to this function might be:

     name:string¦x:float¦y:float¦origin:origin¦

     Here, each property is delimited by a '¦'. Keyname and type
     are delimited by ':'.
     */
    describe(description) {
        let schema = {}, parts = [];

        description.split('¦').forEach((attribute) => {
            let [key, value] = attribute.split(':');

            if (key && value) {
                schema[key] = value;
            }
        });
        this.schema = schema;
    }

    // Get a value from a member of this pool by index.
    getFromMember(index, attribute) {
        let value = this.members[index].values[attribute];

        if (value && value.transforms && value.transforms.length > 0) {
            return this.transformedValue(value);
        }
        return value;
    }

    // Given a set of params, return a member of this pool.
    member(params) {
        let {authToken, keys, latency, values} = params,
            l = values.length,
            member = this.members[values[0]] || this.defaultMember(),
            self = this;

        while (l--) {
            let key = keys[l],
                value = values[l],
                type = this.schema[key];

            member.values[key] = this.valueForType(value, type, latency, authToken);
            member[key] = function() {
                if (type === 'string' || type === 'origin') {
                    return this.values[key].precise;
                }
                return self.transformedValue(this.values[key]);
            };
        }
        return member;
    }

    // Given a set of params, return a member of this pool.
    modifyMember(member, params) {
        let {authToken, keys, latency, values} = params,
            l = values.length,
            self = this;

        while (l--) {
            let key = keys[l],
                value = values[l],
                type = this.schema[key];

            member.values[key] = this.valueForType(value, type, latency, authToken);
        }
        return member;
    }

    // Remove a member from this pool by index.
    removeMember(index) {
        let member = this.members[index];

        if (member) {
            delete this.members[index];
            return member;
        }
        return false;
    }

    /*
     Handle a sync packet, a type of packet used to update the state
     of multiple members of a pool at once. A sync packet might look
     something like the following:

     name¦x¦y:1¦Avatar¦0¦0„2¦Iolo¦3¦2„3¦Jaana¦3¦2

     Before the ':' is a list of keys. After it, is a list of pool
     members delimited by '„'. Each member has a delimiter, '¦'.
     The first element is the index of the pool member and the rest
     are values for the keys that begin the packet.

     This returns an object containing the created and updated
     members within separate objects. These are passed to the
     poolSync state callback which eventually pass them to the
     poolCreate and poolUpdate state callbacks respectively.
     */
    sync(event) {
        let parts = event.params[0].split(/:(.+)?/),
            keys = parts[0].split('¦'),
            members = parts[1].split('„').map((member) => {
                return member.split('¦');
            }),
            l = members.length,
            createdMembers = {},
            updatedMembers = {};

        while (l--) {
            let index = members[l][0],
                isNew = !(this.members[index]);

            if (members[l].length - 1 === keys.length) {
                let params = {
                        authToken: event.authToken,
                        latency: event.latency,
                        keys: keys,
                        values: members[l].slice(1)
                };
                if (isNew) {
                    this.members[index] = this.member(params);
                    createdMembers[index] = this.members[index];
                } else {
                    this.modifyMember(this.members[index], params);
                    updatedMembers[index] = this.members[index];
                }
            }
        }
        return {
            created: createdMembers,
            updated: updatedMembers
        };
    }

    // Split each transform string for a collection of transforms.
    transformsFrom(transforms) {
        return transforms.map((transform) => {
            return transform.split(':');
        });
    }

    // Return a value, applying all transforms and taking into
    // account latency.
    transformedValue(value) {
        var precise = value.precise,
            transforms = value.transforms || [],
            added = 0,
            l = transforms.length;

        while (l--) {
            added += (Date.now() + value.latency - value.started) * transforms[l][1];
        }
        return precise + added;
    }

    // Return the correct value object for a type.
    valueForType(value, type, latency, authToken) {
        var parts = value.split('›'),
            precise = parts[0],
            transforms = this.transformsFrom(parts.slice(1));

        switch (type) {
        case 'float':
            return {
                latency: latency,
                precise: parseFloat(precise),
                started: Date.now(),
                transforms: transforms
            };
        case 'int':
            return {
                latency: latency,
                precise: Math.round(precise),
                started: Date.now(),
                transforms: transforms
            };
        case 'string':
            return {
                latency: latency,
                precise: value,
                started: Date.now(),
                transforms: null
            };
        case 'origin':
            return {
                latency: latency,
                precise: value,
                owned: value === authToken,
                started: Date.now(),
                transforms: null
            };
        default:
            return null;
        }
    }

    // Given an event, perform an action on a pool.
    static use(event, pools) {
        console.log(event);

        // if (event.id && !pools[event.id]) {
        //     pools[event.id] = new Pool();
        // }
        switch (event.action) {
        case 'drop':
            break;
        case 'sync':
            // let results = pools[event.id].sync(event);
            // return {
            //     callback: 'poolSync',
            //     params: [results.created, results.updated, event.id]
            // };
            break;
        case 'describe':
            // pools[event.id].describe(event.params[0]);
            break;
        default:
            break;
        }
    }
}
export default Pool;

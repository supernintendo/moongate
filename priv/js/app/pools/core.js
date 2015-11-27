class Pool {
    constructor() {
        this.members = {};
    }
    defaultMember() {
        return {
            get() {
                return this.getFromMember.bind(this, pool, values[0]);
            }
        };
    }
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
    getFromMember(index, attribute) {
        let value = this.members[index][attribute];

        if (value && value.transforms && value.transforms.length > 0) {
            return this.transformedValue(value);
        }
        return value;
    }
    removeMember(index) {
        let member = this.members[index];

        if (member) {
            delete this.members[index];
            return member;
        }
        return false;
    }
    sync(event) {
        let parts = event.params.split(':'),
            batch = parts.slice().splice(1).join(':'),
            attributes = parts[0].split('¦'),
            members = batch.split('„').map((member) => {
                return member.split('¦');
            }),
            l = members.length,
            fresh = [],
            old = [];

        while (l--) {
            let index = members[l][0];

            if (members[l].length - 1 === attributes.length) {
                if (this.members[index]) {
                    fresh.push(this.updateMember(event));
                } else {
                    old.push(this.updateMember(event));
                }
            }
        }
    }
    transformsFrom(transforms) {
        return transforms.map((transform) => {
            return transform.split(':');
        });
    }
    transformedValue(value) {
        var precise = value.precise,
            transforms = value.transforms,
            added = 0,
            l = transforms.length;

        while (l--) {
            added += (Date.now() + value.latency - value.started) * transforms[l][1];
        }
        return precise + added;
    }
    updateMember(event) {
        let {authToken, keys, latency, pool, values} = event,
            l = values.length - 1,
            member = this.members[values[0]] || this.defaultMember();

        while (l--) {
            let value = values[l + 1],
                type = this.schema[keys[l]];

            member[keys[l]] = this.valueForType(value, type, latency, authToken);
        }
        return member;
    }

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
        if (event.id && !pools[event.id]) {
            pools[event.id] = new Pool();
        }
        switch (event.action) {
        case 'drop':
            let result = pools[event.id].removeMember(event.params[0]);

            if (result) {
                return ['poolDrop', [result, event.params[0], event.id]];
            }
            break;
        case 'sync':
            pools[event.id].sync(event);
            break;
        case 'describe':
            pools[event.id].describe(event.params[0]);
            break;
        default:
            break;
        }
    }
}
export default Pool;

const Utils = {
    deepExtend(out) {
        let l = arguments.length;
        out = out || {};

        while (l--) {
            var obj = arguments[l];

            if (!obj) {
                continue;
            }
            for (var key in obj) {
                if (obj.hasOwnProperty(key)) {
                    if (typeof obj[key] === 'object') {
                        this.deepExtend(out[key], obj[key]);
                    } else {
                        out[key] = obj[key];
                    }
                }
            }
        }
        return out;
    },
    camelize(str) {
        return str.replace(/(\_\w)/g, (part) => {
            return part[1].toUpperCase();
        });
    },
    entries(obj) {
        return Object.keys(obj).map((k) => {
            return [k, obj[k]];
        });
    },
    uppercase(str) {
        return str.charAt(0).toUpperCase() + str.slice(1);
    }
}
export default Utils

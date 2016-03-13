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
    }
}
export default Utils

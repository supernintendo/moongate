interface HtmlEntities {
  "&": string;
  "<": string;
  ">": string;
  "\"": string;
  "'": string;
  "/": string;
  "`": string;
  "=": string;
  [key: string]: string;
}
interface Navigator {
  languages: any
}
const htmlEntities: HtmlEntities = {
  "&": "&amp;",
  "<": "&lt;",
  ">": "&gt;",
  "\"": "&quot;",
  "'": "&#39;",
  "/": "&#x2F;",
  "`": "&#x60;",
  "=": "&#x3D;"
}

export class Utility {
  static camelize(input: string) {
    return input.replace(/(\_\w)/g, (m) => m[1].toUpperCase());
  }
  static capitalize(input: string) {
    return input.charAt(0).toUpperCase() + input.slice(1);
  }
  static loop(callback: Function, iterable: any) {
    if (iterable.constructor === Array) {
      for (let i = 0, l = iterable.length; i !== l; i++) {
        callback(iterable[i], i);
      }
    } else if (typeof iterable === "object") {
      let keys = Object.keys(iterable);

      for (let i = 0, l = keys.length; i !== l; i++) {
        callback(iterable[keys[i]], keys[i]);
      }
    } else if (typeof iterable === "number") {
      for (let i = 0, l = iterable; i !== l; i++) {
        callback(i);
      }
    } else {
      throw new TypeError("Moongate.Utility.loop only accepts Array, Object or number as second argument");
    }
  }
  static iterate(callback: Function, collection: Array<any>) {
    for (let i = 0, l = collection.length; i !== l; i++) {
      callback(collection[i], i, callback);
    }
  }
  static escapeHtml(input: string) {
    return String(input).replace(/[&<>"'`=\/]/g, function (chunk: string) {
      return htmlEntities[chunk];
    });
  }
  static metaFields(arg: any) {
    let match = new RegExp("__(.*)__");

    return Object.keys(arg).filter((key) => {
      return !!key.match(match);
    }).reduce((acc : any, key: string) => {
      let chunks = key.match(match);

      acc[chunks[1]] = arg[key];

      return acc;
    }, {});
  }
  static morphedValue(value: any, tween: any, from: any) {
    let now = performance.now() + from,
        delta = (now - tween.startedAt) * tween.amount / tween.interval;

    return value + delta;
  }
  static numberToHex(number: number, padding: number) {
    return (number + Math.pow(16, padding)).toString(16).slice(-padding).toUpperCase();
  }
  static preallocArray(size: number, placeholder: any) {
    let result = new Array(size),
        n = size;

    while (n--) {
      result[n] = placeholder;
    }
    return result;
  }
  static uuid() {
    return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, (c) => {
      let r = Math.random() * 16 | 0, v = c == "x" ? r : (r & 0x3 | 0x8);

      return v.toString(16);
    });
  }
}

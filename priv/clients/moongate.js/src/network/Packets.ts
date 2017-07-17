import { Atlas } from "../client/Atlas";
import { Packet } from "./Packet";

export class Packets {
  static decode(packet: string, atlas: Atlas) : Packet {
    return Packets.decompressPacket({
      body: Packets.splitChunk(packet, "body"),
      handler: Packets.matchChunk(packet, "handler"),
      ring: Packets.matchChunk(packet, "ring"),
      rule: Packets.matchChunk(packet, "rule"),
      zone: Packets.matchChunk(packet, "zone")
    }, atlas.packet.compressor);
  }
  static encode(packet: Packet, atlas: Atlas) : string {
    let compressor = atlas.packet.compressor;

    return (
      "#" +
      Packets.encodeChunk(packet.handler, "[", "]", compressor) +
      Packets.encodeChunk(packet.zone, "(", ")", compressor) +
      Packets.encodeChunk(packet.ring, "{", "}", compressor) +
      Packets.encodeChunk(packet.rule, "<", ">", compressor) +
      Packets.encodeBody(packet.body)
    );
  }
  static matchChunk(packet: string, key: string) : any {
    var match = packet.match(Packets.patterns()[key]);

    if (match && match[0]) {
      let parts: Array<string> = match[1].split(":");

      if (parts.length === 1) {
        return parts[0];
      }
      return parts;
    }
    return false;
  }
  static patterns() : any {
    return {
      body: /::(.+)?/,
      handler: /\[(.*?)\]/,
      ring: /{(.*?)}/,
      rule: /<(.*?)>/,
      zone: /\((.*?)\)/
    }
  }
  static compressChunk(chunk: string, compressor: any) {
    return compressor.by_word[chunk] || chunk;
  }
  static encodeBody(body: any) {
    if (body) {
      if (body.constructor === Array) {
        let result = `::${body[0]}`;

        for (let i = 1, l = body.length; i !== l; i++) {
          result += `|${body[i]}`;
        }
        return result;
      } else if (typeof body === "object") {
        return `::${JSON.stringify(body)}`;
      }
      return `::${body}`;
    }
    return "";
  }
  static encodeChunk(chunk: any, left: string, right: string, compressor: any) : string {
    if (chunk && chunk.constructor === Array) {
      return Packets.wrapChunk(
        chunk.map((c : string) => {
          return Packets.compressChunk(c, compressor);
        }), left, right
      );
    } else if (chunk) {
      return Packets.wrapChunk(Packets.compressChunk(chunk, compressor), left, right);
    }
    return "";
  }
  static splitChunk(chunk: string, patternKey: string) : string {
    var match = chunk.split(Packets.patterns()[patternKey]);

    return match.slice(1).join("");
  }
  static wrapChunk(chunk: any, left: string, right: string) : string {
    if (chunk && chunk.constructor === Array) {
      return `${left}${chunk.join(":")}${right}`;
    }
    return `${left}${chunk}${right}`;
  }
  static decodeInt(string: string) : number {
    return parseInt(string, 10);
  }
  static decodeList(string: string) : string[] {
    return string.split(",");
  }
  static decodePair(string: string) : any {
    return string.split(/:(.+)/).slice(0, 2);
  }
  static decompressPacket(packet: Packet, compressor: any) : Packet {
    return {
      body: packet.body,
      handler: Packets.decompressField(packet.handler, compressor),
      ring: Packets.decompressField(packet.ring, compressor),
      rule: Packets.decompressField(packet.rule, compressor),
      zone: Packets.decompressZone(packet.zone, compressor)
    };
  }
  static decompressField(field: string, compressor: any) : string {
    return compressor.by_token[field] || field;
  }
  static decompressZone(zoneField: any, compressor: any) : any {
    if (zoneField && zoneField.constructor === Array && zoneField.length == 2) {
      return [
        Packets.decompressField(zoneField[0], compressor),
        zoneField[1]
      ];
    } else if (zoneField) {
      return Packets.decompressField(zoneField, compressor);
    }
    return false;
  }
  static decompressSchemaKeys(schemaString: string, compressor: any) : string[] {
    return schemaString.split("|").map((token : string) => compressor.by_token[token]);
  }
  static decompressMap(mapString: string, schemaKeys: string[]) : any[] {
    let chunks : any[] = mapString.split("&"),
        keys = schemaKeys.sort(),
        members = chunks.map((chunk : string) => chunk.split("|")),
        results : any[] = [];

    for (let i = 0, l = chunks.length; i !== l; i++) {
      let result : any = {};

      for (let j = 0, k = keys.length; j !== k; j++) {
        result[keys[j]] = members[i][j];
      }
      results.push(result);
    }
    return results;
  }
  static decompressMorphs(body: string, compressor: any) : any[] {
    let results : any[] = (
      body.split("&")
          .map((chunk) => chunk.split(":"))
          .map((chunk) => {
            let [selector, tweenChunk] = chunk,
                [rule, key, index] = selector.split("|"),
                tween = Packets.decompressTween(tweenChunk);

              if (tween) {
                return {
                  index: parseInt(index, 10),
                  rule: compressor.by_token[rule],
                  tween: tween,
                  key: compressor.by_token[key]
                };
              }
          })
          .filter((result) => !!result)
    );

    return results;
  }
  static decompressTween(body: string) : any {
    let result = body.match(/(?:~(\d*[1-9]\d*(\.\d+)?|0*\.\d*[1-9]\d*)[d]([-+]?[0-9]+)~([0-9]+))/);

    if (result && result[1] && result[3] && result[4]) {
      return {
        startedAt: parseFloat(result[1]),
        amount: parseFloat(result[3]),
        interval: parseFloat(result[4])
      };
    }
    return false;
  }
  static isKeyValue(body: string) : Boolean {
    return false;
  }
}

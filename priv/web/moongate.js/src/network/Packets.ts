import { Packet } from './Packet';
import { Utility } from '../Utility';

export class Packets {
  static decode(packet: string, packetCompressor: any) : Packet {
    return Packets.decompressPacket({
      body: Packets.splitChunk(packet, 'body'),
      handler: Packets.matchChunk(packet, 'handler'),
      raw: packet,
      ring: Packets.matchChunk(packet, 'ring'),
      rule: Packets.matchChunk(packet, 'rule'),
      zone: Packets.matchChunk(packet, 'zone')
    }, packetCompressor);
  }
  static encode(packet: Packet, packetCompressor: any) : string {
    return (
      '#' +
      Packets.encodeChunk(packet.handler, '[', ']', packetCompressor) +
      Packets.encodeChunk(packet.zone, '(', ')', packetCompressor) +
      Packets.encodeChunk(packet.ring, '{', '}', packetCompressor) +
      Packets.encodeChunk(packet.rule, '<', '>', packetCompressor) +
      Packets.encodeBody(packet.body)
    );
  }
  static matchChunk(packet: string, key: string) : any {
    var match = packet.match(Packets.patterns()[key]);

    if (match && match[0]) {
      let parts: Array<string> = match[1].split(':');

      if (parts.length === 1) {
        return parts[0];
      }
      return parts;
    }
    return null;
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
  static compressChunk(chunk: string, packetCompressor: any) {
    return packetCompressor.by_word[chunk] || chunk;
  }
  static encodeBody(body: any) {
    if (body) {
      if (body instanceof Array) {
        return `::${body.join('|')}`;
      } else if (body instanceof Object) {
        return `::${JSON.stringify(body)}`;
      }
      return `::${body}`;
    }
    return '';
  }
  static encodeChunk(chunk: any, left: string, right: string, packetCompressor: any) : string {
    if (chunk instanceof Array) {
      return Packets.wrapChunk(
        chunk.map((c : string) => {
          return Packets.compressChunk(c, packetCompressor);
        }), left, right
      );
    } else if (chunk) {
      return Packets.wrapChunk(Packets.compressChunk(chunk, packetCompressor), left, right);
    }
    return '';
  }
  static splitChunk(chunk: string, patternKey: string) : string {
    var match = chunk.split(Packets.patterns()[patternKey]);

    return match.slice(1).join('');
  }
  static wrapChunk(chunk: any, left: string, right: string) : string {
    if (chunk instanceof Array) {
      return `${left}${chunk.join(':')}${right}`;
    }
    return `${left}${chunk}${right}`;
  }
  static decodeInt(string: string) : number {
    return parseInt(string, 10);
  }
  static decodeList(string: string) : string[] {
    return string.split(',');
  }
  static decodePair(string: string) : any {
    return string.split(/:(.+)/).slice(0, 2);
  }
  static decompressPacket(packet: Packet, packetCompressor: any) : Packet {
    return {
      body: packet.body,
      handler: Packets.decompressField(packet.handler, packetCompressor),
      ring: Packets.decompressField(packet.ring, packetCompressor),
      rule: Packets.decompressField(packet.rule, packetCompressor),
      zone: Packets.decompressZone(packet.zone, packetCompressor)
    };
  }
  static decompressField(field: string, packetCompressor: any) : string {
    return packetCompressor.by_token[field] || field;
  }
  static decompressZone(zoneField: any, packetCompressor: any) : any {
    if (zoneField instanceof Array && zoneField.length == 2) {
      return [
        Packets.decompressField(zoneField[0], packetCompressor),
        zoneField[1]
      ];
    } else if (zoneField) {
      return Packets.decompressField(zoneField, packetCompressor);
    }
    return null;
  }
  static decompressSchemaKeys(schemaString: string, packetCompressor: any) : string[] {
    return schemaString.split('|').map((token : string) => packetCompressor.by_token[token]);
  }
  static decompressMap(mapString: string, schemaKeys: string[]) : any[] {
    let chunks : any[] = mapString.split('&'),
        keys = schemaKeys.sort(),
        members = chunks.map((chunk : string) => chunk.split('|')),
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
  static decompressMorphs(body: string, packetCompressor: any) : any[] {
    let results : any[] = (
      body.split('&')
          .map((chunk) => chunk.split(':'))
          .map((chunk) => {
            let [selector, tweenChunk] = chunk,
                [rule, key, index] = selector.split('|'),
                tween = Packets.decompressTween(tweenChunk);

              if (tween) {
                return {
                  index: parseInt(index, 10),
                  rule: packetCompressor.by_token[rule],
                  tween: tween,
                  key: packetCompressor.by_token[key]
                };
              }
          })
          .filter((result) => !!result)
    );

    return results;
  }
  static decompressTween(body: string) : any {
    let result = body.match(/(?:~([0-9]+)[d]([-+]?[0-9]+)~([0-9]+))/);

    if (result && result[1] && result[2] && result[3]) {
      return {
        startedAt: parseInt(result[1], 10),
        amount: parseInt(result[2], 10),
        interval: parseInt(result[3], 10)
      };
    }
    return null;
  }
  static isKeyValue(body: string) : Boolean {
    return false;
  }
}

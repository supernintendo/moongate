import { Client } from "../Client";
import { Ring } from "./Ring";
import { Packets } from "../network/Packets";
import { Tether } from "../client/Tether";
import { Utility } from "../common/Utility";

export default {
  attach(packet: any, client: Client) {
    let [key, value] = Packets.decodePair(packet.body);

    client.attach(key, value);

    return {
      key: key,
      value: value
    };
  },
  command(packet: any, client: Client) {
    let [key, args] = Packets.decodePair(packet.body);

    return {
      key: key,
      value: JSON.parse(args)
    };
  },
  dropMembers(packet: any, client: Client) {
    let results = Packets.decodeList(packet.body).map(Packets.decodeInt),
        [zone, zoneName] = packet.zone;

    return client.dropMembers(results, zone, zoneName, packet.ring);
  },
  echo(packet: any, client: Client) {
    console.log(`🔮 ${packet.body}`);

    return packet.body;
  },
  leave(packet: any, client: Client) {
    let [zone, zoneName] = packet.zone;

    return client.destroyZone(zone, zoneName);
  },
  join(packet: any, client: Client) {
    let [zone, zoneName] = packet.zone;

    client.touchZone(zone, zoneName);

    return {
      zone: zone,
      zoneName: zoneName
    };
  },
  ping(packet: any, client: Client) {
    let ping = new Date().getTime() - Packets.decodeInt(packet.body);

    client.ping = ping;

    return client.ping;
  },
  indexMembers(packet: any, client: Client) : any {
    let [zone, zoneName] = packet.zone,
        ring = packet.ring,
        atlas = client.atlas;

    if (atlas.rings[ring]) {
      let schema = atlas.rings[ring],
          schemaKeys = Object.keys(schema),
          results = Packets.decompressMap(packet.body, schemaKeys);

      client.touchZone(zone, zoneName);

      return Ring.representMembers(
        client.upsertMembers(results, zone, zoneName, ring)
      );
    }
    return false;
  },
  showMembers(packet: any, client: Client) : any {
    let [zone, zoneName] = packet.zone,
        chunks = packet.body.split(/:(.+)/),
        ring = packet.ring;

    if (client.zones[zone] && client.zones[zone][zoneName] && client.zones[zone][zoneName].rings[ring]) {
      let keys = Packets.decompressSchemaKeys(chunks[0], client.atlas.packet.compressor),
          members = Packets.decompressMap(chunks[1], keys),
          results = client.upsertMembers(members, zone, zoneName, ring);

      return Ring.representMembers(results);
    }
    return false;
  },
  showMorphs(packet: any, client: Client) : any {
    let morphs = Packets.decompressMorphs(packet.body, client.atlas.packet.compressor),
        [zone, zoneName] = packet.zone,
        results = client.upsertMorphs(morphs, zone, zoneName, packet.ring);

    return results;
  },
  dropMorphs(packet: any, client: Client) : any {
    let [zone, zoneName] = packet.zone,
        [key, indices] = Packets.decodePair(packet.body),
        parsedIndices = Packets.decodeList(indices).map((index) => {
          return parseInt(index, 10)
        });

    client.dropMorphs({
      key: key,
      rule: packet.rule,
    }, parsedIndices, zone, zoneName, packet.ring);

    return {
      indices: parsedIndices,
      key: key,
      zone: zone,
      zoneName: zoneName,
      ring: packet.ring,
      rule: packet.rule
    };
  }
}

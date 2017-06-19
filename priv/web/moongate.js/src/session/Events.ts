import { Packet } from '../network/Packet';
import { Packets } from '../network/Packets';
import { Session } from './Session';

export default {
  attach(packet: Packet, session: Session) {
    let [key, value] = Packets.decodePair(packet.body);

    session.attached[key] = value;
    return value;
  },
  command(packet: Packet, session: Session) {
    let [callbackKey, args] = Packets.decodePair(packet.body);

    return session.handler.clientCallback(
      callbackKey,
      JSON.parse(args),
      session
    );
  },
  dropMembers(packet: Packet, session: Session) {
    let results = Packets.decodeList(packet.body).map(Packets.decodeInt),
        [zone, zoneName] = packet.zone;

    return session.destroyMembers(results, zone, zoneName, packet.ring);
  },
  echo(packet: Packet, session: Session) {
    console.log(`🔮 ${packet.body}`);

    return packet.body;
  },
  leave(packet: Packet, session: Session) {
    let [zone, zoneName] = packet.zone;

    return session.destroyZone(zone, zoneName);
  },
  join(packet: Packet, session: Session) {
    let [zone, zoneName] = packet.zone;

    return session.upsertZone(zone, zoneName);
  },
  ping(packet: Packet, session: Session) {
    let ping = new Date().getTime() - Packets.decodeInt(packet.body);

    session.ping = ping;
    return session.ping;
  },
  indexMembers(packet: Packet, session: Session) : any {
    let [zone, zoneName] = packet.zone,
        ring = packet.ring;

    if (session._.atlas.rings[ring]) {
      let schema = session._.atlas.rings[ring],
          schemaKeys = Object.keys(schema),
          results = Packets.decompressMap(packet.body, schemaKeys);

      session.upsertZone(zone, zoneName)
      return session.upsertMembers(results, zone, zoneName, ring);
    }
    return null;
  },
  showMembers(packet: Packet, session: Session) : any {
    let [zone, zoneName] = packet.zone,
        chunks = packet.body.split(/:(.+)/),
        ring = packet.ring;

    if (session.zones[zone] && session.zones[zone][zoneName] && session.zones[zone][zoneName].rings[ring]) {
      let schema = Packets.decompressSchemaKeys(chunks[0], session._.atlas.packet.compressor),
          results = Packets.decompressMap(chunks[1], schema);

      return session.upsertMembers(results, zone, zoneName, ring);
    }
    return null;
  },
  showMorphs(packet: Packet, session: Session) : any {
    let results = Packets.decompressMorphs(packet.body, session._.atlas.packet.compressor),
        [zone, zoneName] = packet.zone;

    return session.upsertMorphs(results, zone, zoneName, packet.ring);
  }
}

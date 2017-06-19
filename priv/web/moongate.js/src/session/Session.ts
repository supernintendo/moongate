import { Client } from '../Client';
import { Handler } from './EventHandler';
import { Loop } from './GameLoop';
import { Ring } from './Ring';
import { Packet } from '../network/Packet';
import { Zone } from './Zone';

export class Session {
  _: Client
  attached: any
  loop: Loop
  handler: Handler
  ping: number
  zones: any
  constructor(context: Client) {
    this._ = context;
    this.attached = {};
    this.loop = new Loop(this);
    this.handler = new Handler(this._.config);
    this.zones = {};
  }
  handle(packet: Packet) {
    this.handler.callback(packet.handler, packet, this);
  }
  destroyMembers(memberIndices: Array<number>, zone: string, zoneName: string, ring: string) : any {
    if (!this.zones[zone]) { return []; }
    if (!this.zones[zone][zoneName]) { return []; }
    if (!this.zones[zone][zoneName].rings[ring]) { return []; }

    this.zones[zone][zoneName].rings[ring].destroyMembers(memberIndices);

    return {
      indices: memberIndices,
      ring: ring
    };
  }
  destroyZone(zone: string, zoneName: string) {
    if (!this.zones[zone]) { return false; }
    if (!this.zones[zone][zoneName]) { return false; }

    delete this.zones[zone][zoneName];

    return true;
  }
  upsertMembers(members: Array<any>, zone: string, zoneName: string, ring: string) {
    this.upsertRing(zone, zoneName, ring);

    return this.zones[zone][zoneName].rings[ring].upsertMembers(members);
  }
  upsertMorphs(morphs: Array<any>, zone: string, zoneName: string, ring: string) {
    this.upsertRing(zone, zoneName, ring);

    return this.zones[zone][zoneName].rings[ring].upsertMorphs(morphs);
  }
  upsertZone(zone: string, zoneName: string) {
    if (!this.zones[zone]) {
      this.zones[zone] = {};
    }
    if (!this.zones[zone][zoneName]) {
      this.zones[zone][zoneName] = new Zone();
    }
    return this.zones[zone][zoneName];
  }
  upsertRing(zone: string, zoneName: string, ring: string) {
    this.upsertZone(zone, zoneName);
    if (!this.zones[zone][zoneName].rings[ring]) {
      this.zones[zone][zoneName].addRing(ring, this._.atlas.rings[ring] || {});

      return this.zones[zone][zoneName].rings[ring];
    }
  }
}

import { Atlas } from "../client/Atlas";
import { Ring } from "./Ring";

export class Zone {
  atlas: Atlas
  rings: any
  zone: string
  zoneName: string
  constructor(zone: string, zoneName: string, atlas: Atlas) {
    this.atlas = atlas;
    this.zone = zone;
    this.zoneName = zoneName;
    this.rings = {};
  }
  addRing(ring: string, schema: any) {
    this.rings[ring] = new Ring(this.zone, this.zoneName, ring, schema, this.atlas);
  }
}

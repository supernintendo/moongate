import { Ring } from './Ring';

export class Zone {
  rings: any
  constructor() {
    this.rings = {};
  }
  addRing(name: string, schema: any) {
    this.rings[name] = new Ring(name, schema);
  }
}

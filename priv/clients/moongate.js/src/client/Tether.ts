import { BatchEvent } from '../client/BatchEvent';
import { Client } from '../Client';
import { Meta } from '../common/Meta';
import { Module } from '../common/Module';
import { RingMember } from '../client/RingMember';
import { Utility } from '../common/Utility';
import { Worker } from '../common/Worker';

export class Tether extends Module {
  active: Boolean
  batch: Array<Function>
  consumer: any
  instance: any
  keys: Array<string>
  meta: Meta
  parent: Client
  realtimeKeys: Array<string>
  ring: string
  target: RingMember
  uuid: string
  zone: string
  zoneName: string
  constructor(parent: Client, target: any, consumer: any) {
    super();
    let meta = Utility.metaFields(target.attributes);

    this.parent = parent;
    this.meta = {
      index: meta.index,
      ring: meta.ring,
      zone: meta.zone,
      zoneName: meta.zoneName
    };
    this.consumer = consumer;
    this.keys = Object.keys(target.attributes);
    this.realtimeKeys = [];
    this.target = target;
    this.uuid = Utility.uuid();
    this.consume(this.keys);
  }
  consume(keys: Array<string>) {
    let consumer = this.consumer,
        target = this.target,
        morphedMember = target.morphed();

    if (consumer) {
      for (let i = 0, l = keys.length; i !== l; i++) {
        let key = keys[i];

        consumer[key] = morphedMember[key];
      }
    }
  }
  consumeRealtime() {
    this.consume(this.realtimeKeys);
  }
  populateBatch(enable: boolean) {
    if (enable) {
      let event: BatchEvent = {
        callback: this.consumeRealtime.bind(this),
        uuid: this.uuid
      };
      this.parent.batch.push(event);
    } else {
      this.parent.batch = this.parent.batch.filter((event: BatchEvent) => {
        return event.uuid !== this.uuid;
      });
    }
  }
  realtime(key: string, enable: boolean) {
    if (this.keys.indexOf(key) > -1) {
      if (enable) {
        this.realtimeKeys.push(key);
      } else {
        this.realtimeKeys = this.realtimeKeys.filter((k) => k !== key);
      }
    }
    this.consume([key]);
    this.populateBatch(enable);
  }
  static matches(tether: Tether, compareFields: Meta) {
    let meta = tether.meta;

    return (
      meta.zone === compareFields.zone &&
      meta.zoneName === compareFields.zoneName &&
      meta.ring === compareFields.ring &&
      meta.index === compareFields.index
    );
  }
}

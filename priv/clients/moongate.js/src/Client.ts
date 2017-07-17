/*
  Core module for Moongate.JS. This module provides
  a class, Client. Instances of this class spawn any
  number of isolated workers after being initialized,
  using web workers in the browser and separate proc-
  esses in Node.js. Client instances relay messages
  between these workers and provide an interface for
  subscribing and publishing events to them.

  Only one instance of Client should run at a time.
*/
import { Atlas } from "./client/Atlas";
import { BatchEvent } from "./client/BatchEvent";
import { ClientStatus } from "./client/ClientStatus";
import { Config } from "./client/Config";
import { Env } from "./common/Env";
import { EventHandler } from "./client/EventHandler";
import { HTTPRequest } from "./network/HTTPRequest";
import { MessageEvent } from "./network/MessageEvent";
import { Module } from "./common/Module";
import { Meta } from "./common/Meta";
import { Packets } from "./network/Packets";
import { Tether } from "./client/Tether";
import { Utility } from "./common/Utility";
import { Worker } from "./common/Worker";
import { Zone } from "./client/Zone";

export class Client extends Module {
  atlas: Atlas
  attached: any
  batch: Array<BatchEvent>
  config: Config
  handler: EventHandler
  ping: number
  statusCode: number
  tethers: Array<Tether>
  utils: Function
  workers: any
  zones: any
  constructor(config: Object) {
    super();
    this.batch = [];
    this.statusCode = ClientStatus.Initializing;
    this.config = config;

    // Reflect endpoint if one is not provided
    this.config.hostname = this.config.hostname || Env.localHostname();
    this.config.port = this.config.port || Env.localPort();
    this.config.protocol = this.config.protocol || Env.localProtocol();

    this.atlas = new Atlas({
      startTime: performance.timing.navigationStart
    });
    this.attached = {};
    this.handler = new EventHandler();
    this.tethers = [];
    this.utils = Utility;
    this.workers = {};
    this.zones = {};

    /* Fetch the Atlas (metadata used by clients to
      to make inferences about server) */
    this.atlas.refresh(config, () => {
      Client.spawnCoreWorkers(this);

      Object.freeze(this.workers);
      Object.seal(this);
    });
    return this;
  }
  attach(key: string, value: any) {
    key && (this.attached[key] = value);
  }
  handlePacket(body: string) {
    let packet = Packets.decode(body, this.atlas);

    return this.handler.callback(this, packet.handler, packet);
  }
  handleWorkerMessage(e: MessageEvent) {
    (e.data[0] === "#" && this.handlePacket(e.data)) ||
    (e.data.match(/^C::/) && e.isTrusted && Client.handleWorkerParams(this, e))
  }
  meta(arg: any, key: string) {
    if (typeof key === "string") {
      return arg[`__${key}__`];
    }
    return Utility.metaFields(arg);
  }
  preparePacket(payload: any, additionalFields: any) {
    let result = (
      (typeof payload === "string" && this.config.directives[payload])
      || (typeof payload === "object" && payload)
      || {}
    );
    Utility.loop((key: any) => {
      result[key] = additionalFields[key]
    }, Object.keys(additionalFields || {}));

    return result;
  }
  processBatch() {
    let batch = this.batch;

    for (let i = 0, l = batch.length; i !== l; i++) {
      batch[i].callback();
    }
  }
  send(payload: any, additionalFields: any) {
    let packet: any = {};

    return this.workers.Network.ready && this.postToWorker(
      this.workers.Network,
      Packets.encode(this.preparePacket(payload, additionalFields), this.atlas)
    );
  }
  setStatus(statusCode: number) {
    Client.statusTransition(this, statusCode);
  }
  spawn(workerName: string, path: string) {
    let worker: any = new Worker(path);

    worker.id = Utility.uuid();
    worker.ready = false;
    worker.workerName = workerName;
    worker.onmessage = this.handleWorkerMessage.bind(this);
    worker.cast = (callbackName: string, ...args: any[]) => {
      return this.callOnWorker(worker, callbackName, args);
    };
    worker.inspect = () => this.callOnWorker(worker, "inspect", []);
    worker.send = (message: string) => this.postToWorker(worker, message);
    this.workers[workerName] = worker;

    return worker;
  }
  tether(target: any, consumer: any) {
    let meta = Utility.metaFields(target);

    return (
      meta.zone
      && meta.zoneName
      && meta.ring
      && this.upsertTether(target, consumer)
    );
  }
  status(statusCode: number) {
    let statuses : any = {
      [ClientStatus.Uninitialized]: "uninitialized",
      [ClientStatus.Initializing]: "initializing",
      [ClientStatus.Connecting]: "connecting",
      [ClientStatus.Connected]: "connected",
      [ClientStatus.Reconnecting]: "reconnecting",
      [ClientStatus.Disconnected]: "disconnected",
      [ClientStatus.Kicked]: "kicked",
      [ClientStatus.Banned]: "banned"
    }
    return statusCode && statuses[statusCode] || statuses[this.statusCode] || "unknown";
  }
  dropMembers(memberIndices: Array<number>, zone: string, zoneName: string, ring: string) : any {
    let zones = this.zones;

    return (
      zones[zone] &&
      zones[zone][zoneName] &&
      zones[zone][zoneName].rings[ring] &&
      zones[zone][zoneName].rings[ring].dropMembers(memberIndices) &&
      {
        indices: memberIndices,
        ring: ring,
        zone: zone,
        zoneName: zoneName
      }
    );
  }
  destroyZone(zone: string, zoneName: string) {
    let zones = this.zones;

    return zones[zone] && zones[zone][zoneName] && delete zones[zone][zoneName];
  }
  dropMorphs(morph: any, indices: Array<number>, zone: string, zoneName: string, ring: string) {
    let results = this.zones[zone][zoneName].rings[ring].dropMorphs(morph, indices),
        tethers = this.tethers;

    for (let i = 0, l = indices.length; i !== l; i++) {
      for (let j = 0, k = tethers.length; j !== k; j++) {
        Tether.matches(tethers[j], {
          index: indices[i],
          zone: zone,
          zoneName: zoneName,
          ring: ring
        }) && (tethers[j].realtime(morph.key, false));
      }
    }
    return results;
  }
  member(meta: Meta) {
    let {index, zone, zoneName, ring} = meta;

    return (
      this.zones[zone] &&
      this.zones[zone][zoneName] &&
      this.zones[zone][zoneName].rings[ring] &&
      this.zones[zone][zoneName].rings[ring].getMember(index)
    );
  }
  touchRing(zone: string, zoneName: string, ring: string) {
    this.touchZone(zone, zoneName);

    let zoneInstance = this.zones[zone][zoneName];

    !zoneInstance.rings[ring] && zoneInstance.addRing(ring, this.atlas.rings[ring] || {});

    return zoneInstance.rings[ring];
  }
  touchZone(zone: string, zoneName: string) {
    !this.zones[zone] && (this.zones[zone] = {});
    !this.zones[zone][zoneName] && (this.zones[zone][zoneName] = new Zone(zone, zoneName, this.atlas));

    return this.zones[zone][zoneName];
  }
  upsertMembers(members: Array<any>, zone: string, zoneName: string, ring: string) {
    this.touchRing(zone, zoneName, ring);

    return this.zones[zone][zoneName].rings[ring].upsertMembers(members);
  }
  upsertMorphs(morphs: Array<any>, zone: string, zoneName: string, ring: string) {
    this.touchRing(zone, zoneName, ring);

    let results = this.zones[zone][zoneName].rings[ring].upsertMorphs(morphs),
        tethers = this.tethers;

    for (let i = 0, l = morphs.length; i !== l; i++) {
      for (let j = 0, k = tethers.length; j !== k; j++) {
        Tether.matches(tethers[j], {
          index: morphs[i].index,
          zone: zone,
          zoneName: zoneName,
          ring: ring
        }) && (tethers[j].realtime(morphs[i].key, true));
      }
    }
    return results;
  }
  upsertTether(target: any, consumer: any) {
    let member = this.member(Utility.metaFields(target));

    if (member) {
      let tether = new Tether(this, member, consumer);

      this.tethers.push(tether);

      return true;
    }
    return false;
  }
  static handleClientParams(instance: any, rawData: string) {
    let chunks = rawData.split(/^C::/),
        data = chunks[1] && JSON.parse(chunks[1]);

    return (
      typeof instance[data.callback] === "function"
      && instance[data.callback].apply(instance, data.arguments || [])
    );
  }
  static handleWorkerParams(instance: any, e: MessageEvent) {
    let chunks = e.data.split(/^C::/),
        data = chunks[1] && JSON.parse(chunks[1]);

    return data.callback === "ready" ?
      (Client.ready(instance, e.target)) :
      (
        typeof instance[data.callback] === "function"
        && instance[data.callback].apply(instance, data.arguments || [])
      );
  }
  static ready(instance: Client, worker: Worker) {
    worker.ready = true;

    instance.callOnWorker(worker, "init", [instance.atlas]);

    return true;
  }
  static statusTransition(instance: any, statusCode: number) {
    instance.statusCode = statusCode;

    if (instance.config.callbacks.statusChange) {
      instance.config.callbacks.statusChange(statusCode);
    }
  }
  static spawnCoreWorkers(instance: any) {
    // Spawn all workers once Atlas is fetched.
    if (JSON.stringify(instance.workers) !== "{}") {
      console.error("spawnAllWorkers may only be called on new instances of Client");

      return false;
    }
    instance.workers = {};
    instance.spawn("Network", `Moongate/moongate.js/dist/Moongate.Network.js`);
  }
}

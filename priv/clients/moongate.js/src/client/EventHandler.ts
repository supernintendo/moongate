import { Client } from "../Client";
import { Config } from "../client/Config";
import { Module } from "../common/Module";
import { Utility } from "../common/Utility";
import Events from "./Events";

export class EventHandler extends Module {
  callbacks: any
  constructor() {
    super();
    this.callbacks = Events;
  }
  callback(parent: Client, callbackKey: string, packet: any) {
    let key = Utility.camelize(callbackKey);

    if (this.callbacks[key] && typeof this.callbacks[key] === "function") {
      let result = this.callbacks[key].call(this, packet, parent);

      return (
        key
        && typeof parent.config.callbacks[key] === "function"
        && parent.config.callbacks[key].call(this, result)
      );
    }
    return false;
  }
}

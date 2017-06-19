import { Config } from '../Config';
import { Packet } from '../network/Packet';
import { Session } from './Session';
import { Utility } from '../Utility';
import Events from './Events';

export class Handler {
  callbacks: any
  clientCallbacks: any
  constructor(config: Config) {
    this.callbacks = Events;
    this.clientCallbacks = config.callbacks || {};
  }
  callback(callbackKey: string, packet: Packet, session: Session) {
    let key = Utility.camelize(callbackKey);

    if (this.callbacks[key] && this.callbacks[key] instanceof Function) {
      let result = this.callbacks[key].call(this, packet, session);

      if (this.clientCallbacks[key] && this.clientCallbacks[key] instanceof Function) {
        return this.clientCallbacks[key].apply(this, [result]);
      }
      return result;
    }
    return null;
  }
  clientCallback(key: string, args: any, session: Session) {
    if (this.clientCallbacks[key] && this.clientCallbacks[key] instanceof Function) {
      return this.clientCallbacks[key].apply(this, args.concat(session));
    }
    return null;
  }
}

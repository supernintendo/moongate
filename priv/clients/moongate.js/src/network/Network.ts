import { Atlas } from '../client/Atlas';
import { ClientStatus } from '../client/ClientStatus';
import { Config } from '../client/Config';
import { MessageEvent } from './MessageEvent';
import { Module } from '../common/Module';
import { Socket } from './Socket';
import { Utility } from '../common/Utility';

export class Network extends Module {
  atlas: Atlas
  directives: any
  socket: Socket
  constructor() {
    super();
    this.socket = new Socket(this);
    this.callOnClient("ready", []);

    return this;
  }
  init(atlasData: Object) {
    this.callOnClient("setStatus", [ClientStatus.Connecting]);
    this.atlas = new Atlas(atlasData);
    this.socket.init();
  }
  send(message: string) {
    return this.socket.send(message);
  }
  static handleClientMessage(instance: any, e: MessageEvent) {
    return (
      (e.data[0] === "#" && instance.send(e.data))
      || (e.data.match(/^C::/) && Network.handleClientParams(instance, e.data))
    );
  }
  static handleClientParams(instance: any, rawData: string) {
    let chunks = rawData.split(/^C::/),
        data = chunks[1] && JSON.parse(chunks[1]);

    return (
      typeof instance[data.callback] === "function"
      && instance[data.callback].apply(instance, data.arguments || [])
    );
  }
}

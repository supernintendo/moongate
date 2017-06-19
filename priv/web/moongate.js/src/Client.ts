import { Atlas } from './network/Atlas';
import { Config } from './Config';
import { Packet } from './network/Packet';
import { Session } from './session/Session';
import { Socket } from './network/Socket';
import { Utility } from './Utility';

export class Client {
  Utility: Utility
  atlas: Atlas
  config: Config
  name: String
  session: Session
  socket: Socket
  constructor(config: Object) {
    this.Utility = Utility;
    this.config = config || {};
    this.atlas = new Atlas(this);
    this.session = new Session(this);

    return this;
  }
  init() : boolean {
    this.socket = new Socket(this);

    if (this.config.onConnect) {
      this.config.onConnect.apply(this);
    }
    return true;
  }
  send(packet: Packet) {
    return this.socket.send(packet);
  }
}

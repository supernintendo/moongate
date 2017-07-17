import { ClientStatus } from "../client/ClientStatus";
import { Module } from "../common/Module";
import { Network } from "./Network";
import { Packets } from "./Packets";
import { Utility } from "../common/Utility";

export class Socket extends Module {
  parent: Network
  protocol: string
  ws: WebSocket
  constructor(parent: Network) {
    super();
    this.parent = parent;
  }
  init() {
    this.connect();
  }
  connect() {
    this.protocol = "ws";
    this.ws = new WebSocket("ws://" + this.parent.atlas.ip + ":" + this.parent.atlas.port + "/ws");
    this.ws.onopen = this.onWsOpen.bind(this);
    this.ws.onmessage = this.onWsMessage.bind(this);
    this.ws.onclose = this.onWsClose.bind(this);
  }
  onWsOpen() {
    this.callOnClient("setStatus", [ClientStatus.Connected]);
    this.send(Packets.encode({
      handler: "begin"
    }, this.parent.atlas));
  }
  onWsMessage(message: MessageEvent) {
    this.postToClient(message.data);
  }
  onWsClose() {
  }
  send(message: any) {
    this.ws.send(message);
  }
}

import { Atlas } from './Atlas';
import { Client } from '../Client';
import { Environment } from '../Environment';
import { Packets } from './Packets';
import { Packet } from './Packet';

export class Socket {
  _: Client
  packetCompressor: any
  protocol: string
  ws: WebSocket
  constructor(context: Client) {
    this._ = context;
    this.packetCompressor = context.atlas.packet.compressor;
    this.connect();
  }
  connect() {
    Environment.callByContext(
      () => {
        this.protocol = 'ws';
        this.ws = new WebSocket('ws://' + this._.atlas.ip + ':' + this._.atlas.port + '/ws');
        this.ws.onopen = this.onWsOpen.bind(this);
        this.ws.onmessage = this.onWsMessage.bind(this);
        this.ws.onclose = this.onWsClose.bind(this);
      },
      () => {}
    );
  }
  onWsOpen() {
    this.send({
      handler: 'begin'
    });
  }
  onWsMessage(message: MessageEvent) {
    this._.session.handle(Packets.decode(message.data, this.packetCompressor));
  }
  onWsClose() {
  }
  send(packet: Packet) {
    if (this.protocol === 'ws') {
      this.ws.send(Packets.encode(packet, this.packetCompressor));
    }
  }
}

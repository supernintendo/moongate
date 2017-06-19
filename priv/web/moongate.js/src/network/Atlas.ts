import { Client } from '../Client';
import { Config } from '../Config'
import { Environment } from '../Environment'
import { HTTPRequest } from './HTTPRequest'

export class Atlas {
  _: Client
  ip: string
  packet: any
  port: Number
  rings: any
  version: String
  zones: Object
  constructor(context: Client) {
    this._ = context;
    this.fetch(context.init.bind(context), context.config);
  }
  endpoint(config: Config): string {
    if (config.socketAddress) {
      return config.socketAddress;
    } else {
      let hostname: string = config.origin || Environment.localHostname(),
          port: string = config.port || Environment.localPort(),
          protocol: string = config.port || Environment.localProtocol();

      return `${protocol}//${hostname}:${port}/atlas`;
    }
  }
  fetch(callback: Function, config: Config): boolean {
    return HTTPRequest.fetch(
      this.endpoint(config),
      'json',
      this.done.bind(this, callback)
    );
  }
  done(callback: Function, response: any) {
    this.ip = response.ip;
    this.packet = response.packet;
    this.port = response.port;
    this.rings = response.rings;
    this.version = response.version;
    this.zones = response.zones;
    callback();
  }
}

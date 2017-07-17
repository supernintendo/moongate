import { Config } from "./Config"
import { HTTPRequest } from "../network/HTTPRequest"

export class Atlas {
  ip: string
  packet: any
  port: number
  rings: any
  startTime: number
  version: String
  zones: Object
  constructor(state: any) {
    Atlas.refreshState(this, state);
  }
  endpoint(config: Config): string {
    return `${config.protocol}//${config.hostname}:${config.port}/atlas`;
  }
  fetch(config: Config, callback: Function): XMLHttpRequest {
    return HTTPRequest.fetch(this.endpoint(config), "json", this.done.bind(this, callback));
  }
  refresh(config: Config, callback: Function) {
    this.fetch(config, callback);
  }
  done(callback: Function, response: any) {
    Atlas.refreshState(this, response);
    callback();
  }
  static refreshState(instance: any, state: any) {
    Object.keys(state).forEach((key) => {
      instance[key] = state[key];
    });
  }
}

import { Meta } from "./Meta";
import { Worker } from "./Worker";

declare const postMessage: Function;

export class Module {
  constructor() {
    return this;
  }
  callOnClient(callbackName: string, args: Array<any>) {
    return this.postToClient("C::" + JSON.stringify({
      callback: callbackName,
      arguments: args
    }));
  }
  callOnWorker(worker: Worker, callbackName: string, args: Array<any>) {
    worker.postMessage("C::" + JSON.stringify({
      callback: callbackName,
      arguments: args
    }));
  }
  inspect() {
    console.log(this);
  }
  postToClient(message: string) {
    return postMessage(message);
  }
  postToWorker(worker: Worker, message: string) {
    worker.postMessage(message);
  }
}

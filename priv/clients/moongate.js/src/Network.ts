/*
  Entry point for the Network module. This module
  is executed in a separate thread (web worker in
  browser) and is responsible for communicating
  with the Moongate server (WebSockets in the
  browser).
*/

import { Network } from "./Network/Network";

export default (() => {
  let instance = new Network();

  onmessage = (e: MessageEvent) => {
    return Network.handleClientMessage(instance, e);
  };
  return instance;
})();

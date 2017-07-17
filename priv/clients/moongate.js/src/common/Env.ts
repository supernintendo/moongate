export class Env {
  // Executes one of two callbacks depending on the execution
  // environment. If Moongate is running in a web browser, the
  // first callback is called. If Moongate is running in Node.js,
  // the second callback is called. An exception is thrown if
  // the execution callback is not one of these two.
  static callByContext(browserCallback: Function, nodeCallback: Function) {
    switch (Env.context()) {
      case "browser":
        return browserCallback();
      case "node":
        return nodeCallback();
      default:
        throw Env.contextError();
    }
  }
  static context() {
    let isBrowser: Function = new Function("try { return this === window; } catch(e) { return false; }"),
        isNode: Function = new Function("try { return this === global; } catch(e) { return false; }");

    if (isBrowser()) {
      return "browser";
    } else if (isNode()) {
      return "node";
    }
    return "unknown";
  }
  static contextError() {
    return "Unknown Executation Context";
  }
  static localHostname() {
    return Env.callByContext(
      () => { return window.location.hostname },
      () => { return ""; }
    );
  }
  static localPort() {
    return Env.callByContext(
      () => { return window.location.port },
      () => { return ""; }
    );
  }
  static localProtocol() {
    return Env.callByContext(
      () => { return window.location.protocol },
      () => { return ""; }
    );
  }
  static viewport() {
    return {
      width: window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth,
      height: window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight
    };
  }
}

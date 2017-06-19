import { Environment } from '../Environment';
import { Session } from './Session';

export class Loop {
  _: Session
  queue: Array<any>
  constructor(context: Session) {
    this._ = context;
    this.queue = [];

    Environment.callByContext(
      () => { this.browserLoop() },
      () => { this.nodeLoop() }
    )
  }
  browserLoop() {
    if (this.queue.length === 0) {
      return window.requestAnimationFrame(this.browserLoop.bind(this));
    }
    return window.requestAnimationFrame(this.browserLoop.bind(this));
  }
  nodeLoop() {
  }
  push(element: any) {
    this.queue.push(element);
  }
}

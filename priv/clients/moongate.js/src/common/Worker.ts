export interface Worker {
  id: string
  postMessage: Function
  ready: Boolean
  workerName: string
}

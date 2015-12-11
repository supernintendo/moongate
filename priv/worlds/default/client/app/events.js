class Events {
    constructor() {
        this.listeners = [];
    }
    listenTo(target, event, callback) {
        if (target.listeners) {
            target.listeners.push({
                callback: callback,
                event: event,
                parent: this
            });
        }
    }
    trigger(event) {
        this.listeners.forEach((listener) => {
            if (listener.event === event) {
                listener.callback.apply(listener.parent);
            }
        });
    }
}
export default Events;

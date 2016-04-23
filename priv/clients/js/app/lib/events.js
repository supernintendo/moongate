const Console = require('./console');

class Events {
    constructor() {
    }
    static setToken(id, token) {
        this.state.authToken = token;
        this.callback('authenticated', []);

        this.log('auth', this.state.username);
    }
}
export default Events;

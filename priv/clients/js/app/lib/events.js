const Console = require('./console');

class Events {
    constructor() {
    }
    static setToken(token) {
        this.state.authToken = token;
        this.callback('authenticated', []);

        this.log('auth', this.state.username);

        return token;
    }
}
export default Events;

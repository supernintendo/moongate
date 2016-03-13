const Console = {
    message(term, ...args) {
        let dictTerm = this.dictionary[term],
            params = [];

        if (dictTerm) {
            if (dictTerm instanceof Function) {
                params = dictTerm.apply(this, args);
            } else {
                params = dictTerm;
            }
            if (params.length > 0) {
                params[0] = `🔮 ${params[0]}`
                console.log.apply(console, params);
            }
        }
    },
    dictionary: {
        connected: [
            `%cConnection status:%c CONNECTED.`,
            'background-color: #772ED1; color: #FFFFFF;',
            'color: #002907; font-weight: bold;'
        ],
        disconnected: [
            `%cConnection status:%c DISCONNECTED.`,
            'background-color: #772ED1; color: #FFFFFF;',
            'color: #FF4E50; font-weight: bold;'
        ],
        incomingPacket: function(data) {
            return [
                `%cIncoming:%c ${data}`,
                'background-color: #E3FCE9; color: #272821',
                ''
            ];
        },
        outgoingPacket: function(data) {
            return [
                `%cOutgoing:%c ${data}`,
                'background-color: #FFDFDF; color: #272821',
                ''
            ];
        },
        welcome: function(version) {
            return [
                `%cWelcome to Moongate ${version}.`,
                'background-color: #772ED1; border: 1px solid black; color: #FFFFFF; margin: 3px; padding: 3px;'
            ];
        }
    }
}
export default Console

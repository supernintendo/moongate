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
                params[0] = `${params[0]}`
                console.log.apply(console, params);
            }
        }
    },
    dictionary: {
        auth: function(username) {
            return [
                `🔒 %cAuthenticated%c as ${username}.`,
                'background-color: #0FACD6; color: #121212;',
                ''
            ]
        },
        connected: function(server) {
            return [
                `🌕 %cConnected%c to ${server}`,
                'background-color: #772ED1; color: #FFFFFF;',
                ''
            ];
        },
        disconnected: [
            `🌑 %cDisconnected%c!`,
            'background-color: #F23D31; color: #FFFFFF;',
            ''
        ],
        stageLeave: function(id) {
            return [
                `🌐 %cLeft stage%c ${id}.`,
                'background-color: #F7E1E4; color: #121212;',
                ''
            ];
        },
        stageJoin: function(id) {
            return [
                `🌐 %cJoined stage%c ${id}.`,
                'background-color: #CEE9E5; color: #121212;',
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

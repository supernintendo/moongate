var GameHUD = {
    elements: {
        health: document.getElementById('health'),
        maxHealth: document.getElementById('max-health'),
        rupees: document.getElementById('rupees')
    },
    update: function(params) {
        var k = Object.keys(params),
            l = k.length,
            contents;

        while (l--) {
            if (this.elements[k[l]]) {
                contents = params[k[l]].toString();

                if (this.elements[k[l]].innerHTML !== contents) {
                    this.elements[k[l]].innerHTML = contents;
                };
            }
        }
    }
};

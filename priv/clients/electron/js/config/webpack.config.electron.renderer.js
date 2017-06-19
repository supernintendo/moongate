const path = require('path');

module.exports = {
  config() {
    return {
      entry: [__dirname + '/../src/Renderer.js'],
      output: {
        path: path.join(__dirname, '../dist'),
        filename: 'renderer.js'
      },
      target: 'electron-renderer',
      node: {
        __dirname: false,
        __filename: false
      }
    };
  }
};

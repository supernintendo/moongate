const path = require('path');

module.exports = {
  config() {
    return {
      entry: [__dirname + '/../src/MainWindow.js'],
      output: {
        path: path.join(__dirname, '../dist'),
        filename: 'main.js'
      },
      target: 'electron-main',
      node: {
        __dirname: false,
        __filename: false
      }
    };
  }
};

const path = require('path');

module.exports = {
  config() {
    return {
      entry: [__dirname + '/../src/MoongateElectronClient.ts'],
      output: {
        path: path.join(__dirname, '../dist'),
        filename: 'MoongateElectronClient.js',
        library: 'MoongateElectronClient',
        libraryTarget: 'umd',
        umdNamedDefine: true
      }
    };
  }
};

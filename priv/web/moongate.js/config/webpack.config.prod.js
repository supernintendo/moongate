const webpack = require('webpack');

module.exports = {
  config() {
    return {
      output: {
        filename: 'Moongate.min.js'
      },
      plugins: [
        new webpack.optimize.UglifyJsPlugin({
          minimize: true
        })
      ]
    };
  }
};

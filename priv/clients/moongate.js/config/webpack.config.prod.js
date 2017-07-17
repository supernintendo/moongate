const webpack = require("webpack");

module.exports = {
  config() {
    return {
      output: {
        filename: "[name].min.js"
      },
      plugins: [
        new webpack.optimize.UglifyJsPlugin({
          minimize: true
        })
      ]
    };
  }
};

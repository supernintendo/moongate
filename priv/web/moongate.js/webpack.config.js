const merge = require('deepmerge');
const webpack = require('webpack');
const path = require('path');
const yargs = require('yargs');
const env = process.env.MOONGATE_JS_ENV;
const envs = {
  prod: require('./config/webpack.config.prod')
}
const envConfig = envs[env] ? envs[env].config() : {};

module.exports = merge({
  entry: [__dirname + '/src/Client.ts'],
  devtool: 'source-map',
  output: {
    path: path.join(__dirname, '/dist'),
    filename: 'Moongate.js',
    library: 'Moongate',
    libraryTarget: 'umd',
    umdNamedDefine: true
  },
  module: {
    preLoaders: [
      { test: /\.ts/, loader: 'tslint', exclude: /node_modules/ }
    ],
    loaders: [
      { test: /\.ts/, loader: 'ts', exclude: /node_modules/ }
    ]
  },
  resolve: {
    root: path.resolve('./src'),
    extensions: ['', '.js', '.ts']
  },
  plugins: [],
  tslint: {
    emitErrors: true,
    failOnHint: true
  }
}, envConfig, {
  arrayMerge: (target, source) => source
});

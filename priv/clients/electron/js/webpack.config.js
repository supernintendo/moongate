const merge = require('deepmerge');
const webpack = require('webpack');
const path = require('path');
const yargs = require('yargs');
const buildStep = process.env.MOONGATE_ELECTRON_CLIENT_BUILD_STEP;
const buildSteps = {
  moongateElectronClient: require('./config/webpack.config.moongate-electron-client'),
  main: require('./config/webpack.config.electron.main'),
  renderer: require('./config/webpack.config.electron.renderer')
}
const buildStepConfig = buildSteps[buildStep] ? buildSteps[buildStep].config() : {};

module.exports = merge({
  devtool: 'source-map',
  module: {
    preLoaders: [
      { test: /\.ts/, loader: 'tslint', exclude: /node_modules/ }
    ],
    loaders: [
      { test: /\.ts/, loader: 'ts', exclude: /node_modules/ },
      { test: /\.(html)$/, loader: "static-loader" },
      { test: /\.json$/, loader: 'json-loader' },
      { test: /\.(scss|sass)$/, loaders: ['style-loader', 'css-loader', 'sass-loader'] }
    ]
  },
  resolve: {
    root: path.resolve('./src'),
    extensions: ['', '.js', '.ts']
  },
  tslint: {
    emitErrors: true,
    failOnHint: true
  }
}, buildStepConfig, {
  arrayMerge: (target, source) => source
});

const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const webpack = require('webpack');

module.exports = {
  entry: './index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'index.js',
  },
  plugins: [
    new HtmlWebpackPlugin(),
    new webpack.ProvidePlugin({
      TextDecode: ['text-encoding', 'TextDecoder'],
      TextEncode: ['text-encoding', 'TextEncoder']
    })
  ],
  mode: 'development'
};

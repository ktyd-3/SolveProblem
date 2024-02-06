const path = require("path");
const webpack = require("webpack");

module.exports = {
  mode: "production",
  devtool: "source-map",
  entry: {
    application: "./app/javascript/application.js",
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[file].map",
    path: path.resolve(__dirname, "app/assets/builds"),
  },
  optimization: {
    splitChunks: {
      chunks: "all",
      name: "vendor",
    },
  },
  node: {
    global: false,
    __filename: false,
    __dirname: false,
  },
};

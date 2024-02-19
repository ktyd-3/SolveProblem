{
  "name": "app",
  "private": true,
  "scripts": {
    "build": "webpack --config ./config/webpack/webpack.config.js"
  },
  "devDependencies": {
    "webpack": "^5.90.1",
    "webpack-cli": "^5.1.4"
  },
  "dependencies": {
    "@hotwired/turbo-rails": "^7.3.0",
    "bootstrap": "^5.3.2",
    "chartkick": "^5.0.1",
    "css-loader": "^6.10.0",
    "mini-css-extract-plugin": "^2.8.0",
    "sass": "^1.70.0",
    "sass-loader": "^14.1.0",
    "webpack-remove-empty-scripts": "^1.0.4"
  }
}
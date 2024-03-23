// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
//= require clipboard

import "@hotwired/turbo-rails";
import "controllers";
import "chartkick";
import "Chart.bundle";
import "jquery";
import { fas } from "@fortawesome/free-solid-svg-icons";
import { far } from "@fortawesome/free-regular-svg-icons";
import { fab } from "@fortawesome/free-brands-svg-icons";
import { library } from "@fortawesome/fontawesome-svg-core";
import "@fortawesome/fontawesome-free";
library.add(fas, far, fab);
import jquery from "jquery";
window.$ = jquery;

document.addEventListener("turbo:load", function () {
  var clipboard = new Clipboard(".clipboard-btn");
  console.log(clipboard);
});

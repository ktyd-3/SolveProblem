const { environment } = require("@rails/webpacker");

// 追加
// ここから
const customConfig = {
  resolve: {
    fallback: {
      dgram: false,
      fs: false,
      net: false,
      tls: false,
      child_process: false,
    },
  },
};

environment.config.delete("node.dgram");
environment.config.delete("node.fs");
environment.config.delete("node.net");
environment.config.delete("node.tls");
environment.config.delete("node.child_process");

environment.config.merge(customConfig);
// ここまで

module.exports = environment;

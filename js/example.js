const N = 4; // number of bytes to encode message length
const NodePort = require("node-port-js");
const fs = require("fs");
const reader = new NodePort.Reader(fs.createReadStream(null, {fd: 3}), N, {debug: true});
const writer = new NodePort.Writer(fs.createWriteStream(null, {fd: 4}), N, {debug: true});

reader.on("data", data => {
  console.log("-- received:")
  console.log(data)
  console.log("--\n")

  if (data === "HALT") {
    writer.write("stopping");
    process.exit(0);
  }
  var data = JSON.parse(data);
  writer.write(`x was ${data.x}`);
});

process.stdin.on("end", () => { process.exit(0); });

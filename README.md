# NodePort

Communicate with a Node.js process pool through ports.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add node_port to your list of dependencies in `mix.exs`:

        def deps do
          [{:node_port, "~> 0.0.1"}]
        end

  2. Ensure node_port is started before your application:

        def application do
          [applications: [:node_port]]
        end

## Example Usage

Each message encodes the length of the message as a big-endian 32-bit integer at the beginning of the message. I made a tiny package to help read that kind of message in node.js ( https://github.com/TurplePurtle/node-port ). Using that, here is an example:

In `js/main.js`:

```javascript
const N = 4; // number of bytes to encode message length
const NodePort = require("node-port");
const reader = new NodePort.Reader(process.stdin, N);
const writer = new NodePort.Writer(process.stdout, N);

reader.on("data", e => writer.write(`got data: ${e.data.x}`));

process.stdin.on("end", () => { process.exit(0); });
```

In Elixir:

```elixir
NodePort.start :normal, [
  name: :node_pool,
  command: "node js/main.js",
  size: 2, max_overflow: 2]
NodePort.request :node_pool, "{\"x\": 42}"
```

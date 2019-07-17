var wasmMem = new WebAssembly.Memory({initial: 1});

function printStr(offset, length) {
  var bytes = new Uint8Array(wasmMem.buffer, offset, length);
  var string = new TextDecoder('utf-8').decode(bytes);
  console.log(string);
}

fetch("./hello.wasm")
  .then(response => response.arrayBuffer())
  .then(
    bytes => WebAssembly.instantiate(bytes, {
      js: {
        print: printStr,
        mem: wasmMem,
      }
    })
  ).then(result => result.instance.exports.hello());

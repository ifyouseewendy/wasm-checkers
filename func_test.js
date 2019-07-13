fetch("./func_test.wasm").then(
  response => response.arrayBuffer()
).then(
  bytes => WebAssembly.instantiate(bytes)
).then(
  results => {
    console.log("Loaded wasm module");
    instance = results.instance;
    console.log("instance", instance);

    var black = 1;
    var white = 2;
    var crown = 4;
    var crowned_black = 5;
    var crowned_white = 6;

    console.log("Calling offset");
    var offset = instance.exports.offsetForPosition(3, 4);
    console.log("Offset for 3,4 is expected to be 140", offset);

    console.debug("White is white?", instance.exports.isWhite(white));
    console.debug("Black is black?", instance.exports.isBlack(black));
    console.debug("Black is white?", instance.exports.isWhite(black));
    console.debug("Uncrowned white is ", instance.exports.isWhite(instance.exports.withoutCrown(crowned_white)))
    console.debug("Uncrowned black is ", instance.exports.isBlack(instance.exports.withoutCrown(crowned_black)))
    console.debug("Crowned is crowned (black)", instance.exports.isCrowned(crowned_black));
    console.debug("Crowned is crowned (white)", instance.exports.isCrowned(crowned_white));
  }
)

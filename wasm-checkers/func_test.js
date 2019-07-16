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

    console.log("-- Offset calculation");
    var offset = instance.exports.offsetForPosition(3, 4);
    console.debug("Offset for (3,4) is expected to be 140", offset);

    console.log("-- Board piece state prediction");
    console.debug("White is white?", instance.exports.isWhite(white));
    console.debug("Black is black?", instance.exports.isBlack(black));
    console.debug("Black is white?", instance.exports.isWhite(black));
    console.debug("Uncrowned white is ", instance.exports.isWhite(instance.exports.withoutCrown(crowned_white)))
    console.debug("Uncrowned black is ", instance.exports.isBlack(instance.exports.withoutCrown(crowned_black)))
    console.debug("Crowned is crowned (black)", instance.exports.isCrowned(crowned_black));
    console.debug("Crowned is crowned (white)", instance.exports.isCrowned(crowned_white));

    console.log("-- Board piece getter and setter");
    console.debug("Get piece (3,4):", instance.exports.getPiece(3, 4))
    console.debug("Set piece (3,4) to 1", instance.exports.setPiece(3, 4, 1))
    console.debug("Get piece (3,4):", instance.exports.getPiece(3, 4))

    console.log("-- Turn owner");
    console.debug("Currnet turn owner:", instance.exports.getTurnOwner())
    console.debug("Toggle turn owner", instance.exports.toggleTurnOwner())
    console.debug("Currnet turn owner:", instance.exports.getTurnOwner())
    console.debug("Is black's turn:", instance.exports.isPlayerTurn(1))
    console.debug("Toggle turn owner", instance.exports.toggleTurnOwner())
    console.debug("Currnet turn owner:", instance.exports.getTurnOwner())
  }
)

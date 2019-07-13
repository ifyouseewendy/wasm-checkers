## Checkers

Code example from Programming WebAssembly with Rust: using raw wat to write a checkers board game.

To compile and inspect

```sh
$ wat2wasm checkers.wat
$ wasm-objdump checkers.wasm -x
```

To test, it has to be wrapped into JavaScript. Use `$ ruby -run -e httpd . -p 9090` to init a local server and visit http://localhost:9090/func_test.html



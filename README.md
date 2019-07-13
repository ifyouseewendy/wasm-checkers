## WASM Checkers

Code example from Programming WebAssembly with Rust: using raw wat to write a checkers board game.

### Compile and inspect

* Dependency: [WebAssembly/wabt](https://github.com/WebAssembly/wabt)

```sh
$ wat2wasm checkers.wat
$ wasm-objdump checkers.wasm -x


checkers.wasm:  file format wasm 0x1

Section Details:

Type[2]:
 - type[0] (i32, i32) -> i32
 - type[1] (i32) -> i32
Function[7]:
 - func[0] sig=0
 - func[1] sig=0
 - func[2] sig=1
 - func[3] sig=1
 - func[4] sig=1
 - func[5] sig=1
 - func[6] sig=1
Memory[1]:
 - memory[0] pages: initial=1
Global[3]:
 - global[0] i32 mutable=0 - init i32=1
 - global[1] i32 mutable=0 - init i32=2
 - global[2] i32 mutable=0 - init i32=4
Code[7]:
 - func[0] size=10
 - func[1] size=11
 - func[2] size=10
 - func[3] size=10
 - func[4] size=10
 - func[5] size=7
 - func[6] size=7
```

### Test

The wasm module has to be running on a host, which is wrapped in JavaScript in the code. Use `$ ruby -run -e httpd . -p 9090` to init a local server and visit http://localhost:9090/func_test.html



According to [golang/go WebAssembly](https://github.com/golang/go/wiki/WebAssembly):

```sh
$ GOOS=js GOARCH=wasm go build -o hello.wasm
```

File size comparison

```sh
$ go build -o hello
$ wasm2wat hello.wasm -o hello.wat
$ la

.rwxr-xr-x 2.1M wendi 21 Jul 11:27 hello
.rw-r--r--   79 wendi 21 Jul 11:20 hello.go
.rwxr-xr-x 2.6M wendi 21 Jul 11:22 hello.wasm
.rw-r--r--  72M wendi 21 Jul 11:27 hello.wat 🙀
```


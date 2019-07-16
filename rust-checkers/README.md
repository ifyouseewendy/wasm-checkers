### Checkers (Rust version)

To compile

```sh
$ cd rustycheckers

# Add wasm target to stable toolchain
$ rustup target add wasm32-unknown-unknown --toolchain stable

# Build release
$ cargo build --release --target=wasm32-unknown-unknown

# Move to demo folder
$ cp target/wasm32-unknown-unknown/release/rustycheckers.wasm demo/
```

Run by visit http://localhost:9090/rustycheckers/demo/

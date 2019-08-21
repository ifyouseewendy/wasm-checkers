## WASM hello world example

1. Edit `hello_world.wat`
2. Transform to wasm, `wat2wasm hello_world.wat`
3. Init a server via `ruby -run -e httpd . -p 9090` (to avoid CORS) and visit http://localhost:9090/index.html

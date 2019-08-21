(module
  (import "js" "print"
    (func $js_print (param i32 i32))
  )
  (import "js" "mem" (memory 1))

  (; write to memory ;)
  (data (i32.const 0) "hello world!")

  (; define and export run func ;)
  (func $run
    (; pass memory pointer to imported print function ;)
    (call $js_print (i32.const 0) (i32.const 12))
  )
  (export "run" (func $run))
)

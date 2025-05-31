(module
  (import "env" "log" (func $log (param i32)))

  (func $btn
    (param $beta     f32)
    (param $gamma    f32)
    (param $variance f32)
    (param $mean     f32)
    (param $value    f32)
    (result f32)

    (local $epsilon      f32)
    
    f32.const 0.00001
    local.set $epsilon

    ;; x1 = xij - μ 
    local.get $value
    local.get $mean
    f32.sub

    ;; x2 = √σ²+ε
    local.get $variance
    local.get $epsilon
    f32.add
    f32.sqrt

    ;; x3 = x1/x2
    f32.div

    ;; x4 = γ * x3
    local.get $gamma
    f32.mul

    ;; y = beta + x4
    local.get $beta
    f32.add
  )

  (func $relu (param $x f32) (result f32)
    f32.const 0
    local.get $x
    f32.max
  )

  (func $relu6 (param $x f32) (result f32)
    f32.const 0
    local.get $x
    f32.max

    f32.const 6
    f32.min
  )

  ;; Export functions
  (export "btn" (func $btn))
  (export "relu" (func $relu))
  (export "relu6" (func $relu6))
)


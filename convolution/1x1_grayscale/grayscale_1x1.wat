(module
  (import "env" "log" (func $log (param i32)))
  ;; Export a linear memory of at least 1 page (64KiB)
  (memory (export "memory") 1)

  ;; Convolution 1x1 over RGB565 image with customizable strides
  (func $convolve_grayscale_1x1
    (param $img       i32)  ;; input ptr (GRAYSCALE, 1 bytes/pixel)
    (param $h         i32)  ;; image height
    (param $w         i32)  ;; image width
    (param $stride_h  i32)  ;; vertical stride
    (param $stride_w  i32)  ;; horizontal stride
    (param $out       i32)  ;; output ptr (i32 per pixel)
    (param $k         i32)  ;; kernel gray weight
    (local $i         i32)
    (local $j         i32)
    (local $idx_img   i32)
    (local $gray      i32)
    (local $sum       i32)
    (local $out_ptr   i32)

    ;; initialize row index and output pointer
    i32.const 0
    local.set $i
    local.get $out
    local.set $out_ptr

    block $break_i
      loop $loop_i
        ;; for each column
        i32.const 0
        local.set $j
        block $break_j
          loop $loop_j
            ;; compute input index: i * w + j
            local.get $i
            local.get $w
            i32.mul
            local.get $j
            i32.add
            local.set $idx_img

            ;; load GRAYSCALE pixel
            local.get $img
            local.get $idx_img
            i32.add
            i32.load8_u
            local.tee $gray
            local.get $k
            i32.mul
            local.set $sum

            ;; store at out_ptr and advance
            local.get $out_ptr
            local.get $sum
            i32.store
            local.get $out_ptr
            i32.const 4
            i32.add
            local.set $out_ptr

            ;; j += stride_w
            local.get $j
            local.get $stride_w
            i32.add
            local.tee $j
            local.get $w
            i32.lt_s
            br_if $loop_j
          end
        end
        ;; i += stride_h
        local.get $i
        local.get $stride_h
        i32.add
        local.tee $i
        local.get $h
        i32.lt_s
        br_if $loop_i
      end
    end
  )

  ;; Export functions
  (export "convolve_grayscale_1x1" (func $convolve_grayscale_1x1))
)


(module
  (import "env" "log" (func $log (param i32)))
  ;; Export a linear memory of at least 1 page (64KiB)
  (memory (export "memory") 1)

  ;; Convolution 1x1 over RGB565 image with customizable strides
  (func $convolve_rgb565_1x1
    (param $img       i32)  ;; input ptr (RGB565, 2 bytes/pixel)
    (param $h         i32)  ;; image height
    (param $w         i32)  ;; image width
    (param $stride_h  i32)  ;; vertical stride
    (param $stride_w  i32)  ;; horizontal stride
    (param $out       i32)  ;; output ptr (i32 per pixel)
    (param $k_r       i32)  ;; kernel red weight
    (param $k_g       i32)  ;; kernel green weight
    (param $k_b       i32)  ;; kernel blue weight
    (local $i        i32)
    (local $j        i32)
    (local $idx_img  i32)
    (local $pix      i32)
    (local $r        i32)
    (local $g        i32)
    (local $b        i32)
    (local $sum      i32)
    (local $out_ptr  i32)

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

            ;; load RGB565 pixel
            local.get $img
            local.get $idx_img
            i32.const 2
            i32.mul
            i32.add
            i32.load16_u
            local.set $pix

            ;; extract R, G, B
            local.get $pix
            call $extract_rgb
            local.set $r
            local.set $g
            local.set $b

            ;; weighted sum
            local.get $r
            local.get $k_r
            i32.mul
            local.get $g
            local.get $k_g
            i32.mul
            i32.add
            local.get $b
            local.get $k_b
            i32.mul
            i32.add
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

  ;; Extract R, G, B from a 16-bit RGB565 pixel
  (func $extract_rgb (param $pixel_bytes_16bits i32) (result i32) (result i32) (result i32)
    (local $red i32)
    (local $green i32)
    (local $blue i32)

    ;; o operador AND extrai e o OR junta
    ;; extrair o RED
    local.get $pixel_bytes_16bits
    i32.const 3
    i32.shr_u ;; empilha o resultado do bitwise do deslocamento de 3 bits

    i32.const 31 ;; empilha o 31 [11111]
    i32.and ;; empilha o resultado apos a operacao AND = RED

    local.set $red

    ;; extrair o BLUE
    local.get $pixel_bytes_16bits
    i32.const 8
    i32.shr_u ;; empilha o resultado do bitwise do deslocamento de 8 bits

    i32.const 31 ;; empilha o 31 [11111]
    i32.and ;; empilha o resultado apos a operacao AND = BLUE

    local.set $blue

    ;; extrair o GREEN parte 1
    local.get $pixel_bytes_16bits
    i32.const 13
    i32.shr_u ;; empilha o resultado do bitwise do deslocamento de 13 bits
    i32.const 7 ;; empilha o 7 [111]
    i32.and ;; empilha o resultado apos a operacao AND = GREEN parte 1

    ;; extrair o GREEN parte 2 e junta com o GREE parte 1 formando o GREEN
    local.get $pixel_bytes_16bits
    i32.const 7 ;; empilha o 7 [111]
    i32.and ;; empilha o resultado apos a operacao AND = GREEN parte 2
    i32.const 3
    i32.shl               ;; $lsb << 3
    i32.or                ;; ($lsb << 3) | $msb
    local.set $green

    ;;;;;;;;;;;;;;;;;;;;
    ;; return RGB565
    ;; Red
    ;; Green
    ;; Blue
    local.get $blue
    local.get $green
    local.get $red
  )

  ;; Export functions
  (export "convolve_rgb565_1x1" (func $convolve_rgb565_1x1))
  (export "extract_rgb"          (func $extract_rgb))
)


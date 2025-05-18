(module 
    (import "env" "log" (func $log (param i32))) ;; Importa print do host
    (memory $mem 2)

    (global $W (mut i32) (i32.const 5)) ;; largura da imagem
    (global $H (mut i32) (i32.const 5)) ;; altura da imagem
    (global $addr (mut i32) (i32.const 0)) ;; endereço inicial da imagem na memória

    (func $extract_rgb (result i32)
        (local $pixel_bytes_16bits i32)
        (local $red i32)
        (local $green_1 i32)
        (local $green i32)
        (local $blue i32)

        i32.const 0
        i32.load16_u ;; ele pega o indice 1 e depois o 0: Big-Endian
        local.set $pixel_bytes_16bits

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

        i32.const 3
        i32.shl ;; [111000] deslocou 3 bits para a esquerda
        local.set $green_1

        ;; extrair o GREEN parte 2 e junta com o GREE parte 1 formando o GREEN
        local.get $pixel_bytes_16bits
        i32.const 7 ;; empilha o 7 [111]
        i32.and ;; empilha o resultado apos a operacao AND = GREEN parte 2

        local.get $green_1
        i32.or

        local.set $green

        ;;;;;;;;;;;;;;;;;;;;
        ;; return RGB565
        ;; Red << 11
        local.get $red
        i32.const 11
        i32.shl

        ;; Green << 5
        local.get $green
        i32.const 5
        i32.shl

        i32.or ;; junta Red e Green

        ;; OR com Blue
        local.get $blue
        i32.or
    )
    (func $pad_image (param $wh_img i32) (param $wh_stride i32) (param $wh_kernel i32) (result i32 i32)
        (local $wh_padding i32)

        (local $left_top i32)
        (local $right_bottom i32)

        local.get $wh_img           ;; numerador
        local.get $wh_stride        ;; denominador
        i32.const 1                 ;; processo para arredondar para cima
        i32.sub                     ;; y - 1
        i32.add                     ;; x + (y - 1)
        local.get $wh_stride        ;; y
        i32.div_u                   ;; resultado = (x + y - 1) / y

        ;; Padding Width - Left and Right,  Height - Top and Botton
        i32.const 1                 ;; 1
        i32.sub                     ;; wh_output - 1
        local.get $wh_stride
        i32.mul                     ;; * wh_stride
        local.get $wh_kernel
        i32.add                     ;; + wh_kernel
        local.get $wh_img
        i32.sub                     ;; - wh_img
        local.set $wh_padding
        ;; ((height_output -1) * height_stride) + height_kernel - height_img

        ;; encontrar o padding da largura (esquerda e direita) ou
        ;; encontrar o padding da altura (top e bottom)
        local.get $wh_padding       ;; salva o resultado na variavel
        i32.const 0
        i32.lt_s                    ;; is less than zero

        (if (result i32 i32)
            (then
                i32.const 0
                local.set $left_top

                i32.const 0
                local.set $right_bottom

                local.get $left_top
                local.get $right_bottom
                return
            )
            (else
                local.get $wh_padding
                i32.const 2             ;; formula padding_total / 2
                i32.div_u

                local.set $left_top

                local.get $wh_padding
                local.get $left_top
                i32.sub

                local.set $right_bottom

                local.get $left_top
                local.get $right_bottom
                return
            )
        )
    )
    
    ;; função principal
    (func $convolve_apply_kernel (export "convolve_apply_kernel")
  (param $img_ptr i32)
  (param $height_real i32)
  (param $width_real i32)
  (param $pad_top i32)
  (param $pad_bottom i32)
  (param $pad_left i32)
  (param $pad_right i32)
  (param $stride_h i32)
  (param $stride_w i32)
  (param $kernel_h i32)
  (param $kernel_w i32)

  ;; auxiliares
  (local $height_total i32) (local $width_total i32)
  (local $out_h i32) (local $out_w i32)
  (local $output_ptr i32) (local $kernel_ptr i32)
  (local $i_out i32) (local $j_out i32)
  (local $ii i32) (local $jj i32)
  (local $k i32) (local $delta_i i32) (local $delta_j i32)
  (local $row i32) (local $col i32) (local $idx i32)
  (local $pixel i32) (local $peso i32) (local $soma i32)

  ;; height_total = pad_top + height_real + pad_bottom
  local.get $pad_top
  local.get $height_real
  i32.add
  local.get $pad_bottom
  i32.add
  local.set $height_total

  ;; width_total = pad_left + width_real + pad_right
  local.get $pad_left
  local.get $width_real
  i32.add
  local.get $pad_right
  i32.add
  local.set $width_total

  ;; out_h = ((height_total - kernel_h) / stride_h) + 1
  local.get $height_total
  local.get $kernel_h
  i32.sub
  local.get $stride_h
  i32.div_u
  i32.const 1
  i32.add
  local.set $out_h

  ;; out_w = ((width_total - kernel_w) / stride_w) + 1
  local.get $width_total
  local.get $kernel_w
  i32.sub
  local.get $stride_w
  i32.div_u
  i32.const 1
  i32.add
  local.set $out_w

  ;; kernel_ptr = img_ptr + height_real * width_real
  local.get $img_ptr
  local.get $height_real
  local.get $width_real
  i32.mul
  i32.add
  local.set $kernel_ptr

  ;; output_ptr = kernel_ptr + kernel_h * kernel_w
  local.get $kernel_ptr
  local.get $kernel_h
  local.get $kernel_w
  i32.mul
  i32.add
  local.set $output_ptr

  ;; i_out loop
  (local.set $i_out (i32.const 0))
  (loop $loop_i
    (local.set $j_out (i32.const 0))
    (loop $loop_j
      (local.set $soma (i32.const 0))

      ;; ii = i_out * stride_h
      local.get $i_out
      local.get $stride_h
      i32.mul
      local.set $ii

      ;; jj = j_out * stride_w
      local.get $j_out
      local.get $stride_w
      i32.mul
      local.set $jj

      ;; loop kernel (k = 0 .. kernel_h * kernel_w)
      (local.set $k (i32.const 0))
      (loop $loop_k
        ;; delta_i = k / kernel_w
        local.get $k
        local.get $kernel_w
        i32.div_u
        local.set $delta_i

        ;; delta_j = k % kernel_w
        local.get $k
        local.get $kernel_w
        i32.rem_u
        local.set $delta_j

        ;; row = ii + delta_i - offset_i
        local.get $ii
        local.get $delta_i
        local.get $kernel_h
        i32.const 1
        i32.sub
        i32.div_u
        i32.sub
        local.set $row

        ;; col = jj + delta_j - offset_j
        local.get $jj
        local.get $delta_j
        local.get $kernel_w
        i32.const 1
        i32.sub
        i32.div_u
        i32.sub
        local.set $col

        ;; verifica se está dentro da imagem
        local.get $row
        i32.const 0
        i32.lt_u
        if (then
          local.set $pixel (i32.const 0)
        ) else
          local.get $row
          local.get $height_real
          i32.lt_u
          if (then
            local.get $col
            i32.const 0
            i32.lt_u
            if (then
              local.set $pixel (i32.const 0)
            ) else
              local.get $col
              local.get $width_real
              i32.lt_u
              if (then
                local.get $img_ptr
                local.get $row
                local.get $width_real
                i32.mul
                local.get $col
                i32.add
                i32.add
                i32.load8_u
                local.set $pixel
              ) else
                local.set $pixel (i32.const 0)
              end
            end
          ) else
            local.set $pixel (i32.const 0)
          end
        end

        ;; peso = i32.load8_s(kernel_ptr + k)
        local.get $kernel_ptr
        local.get $k
        i32.add
        i32.load8_s
        local.set $peso

        ;; soma += pixel * peso
        local.get $soma
        local.get $pixel
        local.get $peso
        i32.mul
        i32.add
        local.set $soma

        ;; próximo k
        local.get $k
        i32.const 1
        i32.add
        local.tee $k
        local.get $kernel_h
        local.get $kernel_w
        i32.mul
        i32.lt_u
        br_if $loop_k
      )

      ;; escreve soma
      local.get $output_ptr
      local.get $i_out
      local.get $out_w
      i32.mul
      local.get $j_out
      i32.add
      i32.add
      local.get $soma
      i32.store

      ;; próximo j_out
      local.get $j_out
      i32.const 1
      i32.add
      local.tee $j_out
      local.get $out_w
      i32.lt_u
      br_if $loop_j
    )
    ;; próximo i_out
    local.get $i_out
    i32.const 1
    i32.add
    local.tee $i_out
    local.get $out_h
    i32.lt_u
    br_if $loop_i
  )
)


    (export "mem" (memory $mem))
    (export "extract_rgb" (func $extract_rgb))
    (export "pad_image" (func $pad_image))
    (export "build_image_padded" (func $build_image_padded))
)
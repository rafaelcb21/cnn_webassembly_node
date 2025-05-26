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

    (func $calculate_padding_4
      (param $h_img i32)      ;; altura da imagem real
      (param $w_img i32)      ;; largura da imagem real
      (param $h_kernel i32)   ;; altura do kernel
      (param $w_kernel i32)   ;; largura do kernel
      (param $stride_h i32)   ;; stride vertical
      (param $stride_w i32)   ;; stride horizontal
      (result i32 i32 i32 i32) ;; retorna: (pad_top, pad_bottom, pad_left, pad_right)

      (local $out_h i32)
      (local $out_w i32)
      (local $pad_h_total i32)
      (local $pad_w_total i32)
      (local $pad_top i32)
      (local $pad_left i32)

      ;; ==== CÁLCULO PARA A ALTURA (TOP/BOTTOM) ====

      ;; out_h = ceil(h_img / stride_h)
      local.get $h_img
      local.get $stride_h
      i32.const 1
      i32.sub
      i32.add
      local.get $stride_h
      i32.div_u
      local.set $out_h

      ;; pad_h_total = ((out_h - 1) * stride_h + h_kernel - h_img)
      local.get $out_h
      i32.const 1
      i32.sub
      local.get $stride_h
      i32.mul
      local.get $h_kernel
      i32.add
      local.get $h_img
      i32.sub
      local.set $pad_h_total

      ;; ==== CÁLCULO PARA A LARGURA (LEFT/RIGHT) ====

      ;; out_w = ceil(w_img / stride_w)
      local.get $w_img
      local.get $stride_w
      i32.const 1
      i32.sub
      i32.add
      local.get $stride_w
      i32.div_u
      local.set $out_w

      ;; pad_w_total = ((out_w - 1) * stride_w + w_kernel - w_img)
      local.get $out_w
      i32.const 1
      i32.sub
      local.get $stride_w
      i32.mul
      local.get $w_kernel
      i32.add
      local.get $w_img
      i32.sub
      local.set $pad_w_total

      ;; ==== AJUSTES ====

      ;; se pad_h_total < 0 então top = bottom = 0
      local.get $pad_h_total
      i32.const 0
      i32.lt_s
      if (result i32 i32)  ;; topo e fundo
        i32.const 0
        i32.const 0
      else
        ;; pad_top = pad_h_total / 2
        local.get $pad_h_total
        i32.const 2
        i32.div_u
        local.tee $pad_top

        ;; pad_bottom = pad_h_total - pad_top
        local.get $pad_h_total
        local.get $pad_top
        i32.sub
      end

      ;; se pad_w_total < 0 então left = right = 0
      local.get $pad_w_total
      i32.const 0
      i32.lt_s
      if (result i32 i32)  ;; esquerda e direita
        i32.const 0
        i32.const 0
      else
        ;; pad_left = pad_w_total / 2
        local.get $pad_w_total
        i32.const 2
        i32.div_u
        local.tee $pad_left

        ;; pad_right = pad_w_total - pad_left
        local.get $pad_w_total
        local.get $pad_left
        i32.sub
      end
    )


    (export "mem" (memory $mem))
    (export "extract_rgb" (func $extract_rgb))
    (export "pad_image" (func $pad_image))
    (export "calculate_padding_4" (func $calculate_padding_4))
)
(module
  (import "env" "log" (func $log (param i32))) ;; Importa print do host
  ;; Export a linear memory of at least 1 page (64KiB)
  (memory (export "memory") 1)

  ;; convolve function signature:
  ;; (param $img i32)       – pointer to first element of input image (i32 array)
  ;; (param $h i32)         – height of the real image
  ;; (param $w i32)         – width of the real image
  ;; (param $pad_t i32)     – top padding
  ;; (param $pad_b i32)     – bottom padding
  ;; (param $pad_l i32)     – left padding
  ;; (param $pad_r i32)     – right padding
  ;; (param $stride_h i32)  – vertical stride
  ;; (param $stride_w i32)  – horizontal stride
  ;; (param $out i32)       – pointer to first element of output buffer (i32 array)

  (func $convolve_rgb565_3x3_valid_first_layer
    (param $img       i32)  ;; ptr para imagem
    (param $h         i32)
    (param $w         i32)
    (param $stride_h  i32)
    (param $stride_w  i32)
    (param $out       i32)  ;; ptr de saída

    (param $k00_r     f32)  ;; RED      - value of kernel by index 00
    (param $k01_r     f32)  ;; RED      - value of kernel by index 01
    (param $k02_r     f32)  ;; RED      - value of kernel by index 02
    (param $k10_r     f32)  ;; RED      - value of kernel by index 10
    (param $k11_r     f32)  ;; RED      - value of kernel by index 11
    (param $k12_r     f32)  ;; RED      - value of kernel by index 12
    (param $k20_r     f32)  ;; RED      - value of kernel by index 20
    (param $k21_r     f32)  ;; RED      - value of kernel by index 21
    (param $k22_r     f32)  ;; RED      - value of kernel by index 22

    (param $k00_g     f32)  ;; GREEN    - value of kernel by index 00
    (param $k01_g     f32)  ;; GREEN    - value of kernel by index 01
    (param $k02_g     f32)  ;; GREEN    - value of kernel by index 02
    (param $k10_g     f32)  ;; GREEN    - value of kernel by index 10
    (param $k11_g     f32)  ;; GREEN    - value of kernel by index 11
    (param $k12_g     f32)  ;; GREEN    - value of kernel by index 12
    (param $k20_g     f32)  ;; GREEN    - value of kernel by index 20
    (param $k21_g     f32)  ;; GREEN    - value of kernel by index 21
    (param $k22_g     f32)  ;; GREEN    - value of kernel by index 22

    (param $k00_b     f32)  ;; BLUE     - value of kernel by index 00
    (param $k01_b     f32)  ;; BLUE     - value of kernel by index 01
    (param $k02_b     f32)  ;; BLUE     - value of kernel by index 02
    (param $k10_b     f32)  ;; BLUE     - value of kernel by index 10
    (param $k11_b     f32)  ;; BLUE     - value of kernel by index 11
    (param $k12_b     f32)  ;; BLUE     - value of kernel by index 12
    (param $k20_b     f32)  ;; BLUE     - value of kernel by index 20
    (param $k21_b     f32)  ;; BLUE     - value of kernel by index 21
    (param $k22_b     f32)  ;; BLUE     - value of kernel by index 22

    (local $out_h     i32) (local $out_w     i32)
    (local $i_out     i32) (local $j_out     i32)
    (local $i         i32) (local $j         i32)
    (local $ki        i32) (local $kj        i32)
    (local $row       i32) (local $col       i32)
    (local $row_img   i32) (local $col_img   i32) 
    (local $row_base  i32) (local $idx       i32) 
    (local $val       i32) (local $sum       f32) 
    (local $sum_r     f32) (local $sum_g     f32) (local $sum_b     f32) 
    (local $idx_ker   i32)
    (local $peso_r    f32) (local $peso_g    f32) (local $peso_b    f32)
    (local $r         f32) (local $g         f32) (local $b         f32)
    (local $kh_len    i32) ;; kernel heigth length, 3x3 = 9
    (local $kw_len    i32) ;; kernel width length,  3x3 = 9

    i32.const 3
    local.set $kh_len ;; define o tamanho da altura do kernel, 3x3 = 9

    i32.const 3
    local.set $kw_len ;; define o tamanho da largura do kernel, 3x3 = 9

    ;; out_h = ((h - kh) / stride_h) + 1
    local.get $h
    local.get $kh_len
    ;;i32.const 3  ;; alterar para 2 3 5 7 dependendo do tamanho do kernel
    i32.sub
    local.get $stride_h
    i32.div_s
    i32.const 1
    i32.add
    local.set $out_h

    ;; out_w = ((w - kw) / stride_w) + 1
    local.get $w
    local.get $kw_len
    ;;i32.const 3  ;; alterar para 2 3 5 7 dependendo do tamanho do kernel
    i32.sub
    local.get $stride_w
    i32.div_s
    i32.const 1
    i32.add
    local.set $out_w

    ;; --- Outer loops over output rows and columns ---
    i32.const 0
    local.set $i_out
    block $break_outer
      loop $outer       ;; number of lines in the image with padding
        ;; i = i_out * stride_h
        local.get $i_out
        local.get $stride_h
        i32.mul
        local.set $i

        i32.const 0
        local.set $j_out
        block $break_inner
          loop $inner
            ;; j = j_out * stride_w
            local.get $j_out
            local.get $stride_w
            i32.mul
            local.set $j

            ;; initialize sum = 0
            f32.const 0
            f32.const 0
            f32.const 0
            f32.const 0
            local.set $sum
            local.set $sum_r ;; RED soma
            local.set $sum_g ;; GREEN soma
            local.set $sum_b ;; BKUE soma

            ;; --- Kernel vertical loop (ki) ---
            i32.const 0
            local.set $ki
            block $break_ki
              loop $loop_ki

                ;; row = i + ki
                local.get $i
                local.get $ki
                i32.add
                local.set $row

                local.get $row
                local.set $row_img

                local.get $row_img
                local.get $w
                i32.mul
                local.set $row_base

                ;; --- Kernel horizontal loop (kj) ---
                i32.const 0
                local.set $kj
                block $break_kj
                  loop $loop_kj
                    ;; col = j + kj
                    local.get $j
                    local.get $kj
                    i32.add
                    local.set $col

                    ;; compute col_img and idx (sem padding)
                    local.get $col
                    local.set $col_img

                    local.get $row_base
                    local.get $col_img
                    i32.add
                    local.set $idx

                    ;; ----- RGB565 (2 byte por pixel) -----
                    ;; endereço = base_img + idx*2
                    local.get $img
                    local.get $idx
                    i32.const 2
                    i32.mul
                    i32.add
                    ;; carrega 2 bytes e faz zero-extend
                    i32.load16_u
                    local.set $val  ;; aqui $val contém o valor RGB565 completo (você pode extrair R/G/B depois)
                    
                    local.get $val
                    call $extract_rgb_f32
                    local.set $r
                    local.set $g
                    local.set $b

                    ;; ki * kernel_w + kj
                    local.get $ki
                    local.get $kw_len
                    ;;i32.const 3  ;; alterar para 2 3 5 7 dependendo do tamanho do kernel
                    i32.mul
                    local.get $kj
                    i32.add
                    local.set $idx_ker
                    
                    (block $end
                      (block $default
                        (block $k22
                          (block $k21
                            (block $k20
                              (block $k12
                                (block $k11
                                  (block $k10
                                    (block $k02
                                      (block $k01
                                        (block $k00
                                          local.get $idx_ker
                                          br_table
                                            $k00 $k01 $k02
                                            $k10 $k11 $k12
                                            $k20 $k21 $k22
                                          br $default
                                        )
                                        ;; $k00
                                        local.get $k00_r
                                        local.set $peso_r
                                        local.get $k00_g
                                        local.set $peso_g
                                        local.get $k00_b
                                        local.set $peso_b
                                        br $end
                                      )
                                      ;; $k01
                                      local.get $k01_r
                                      local.set $peso_r
                                      local.get $k01_g
                                      local.set $peso_g
                                      local.get $k01_b
                                      local.set $peso_b
                                      br $end
                                    )
                                    ;; $k02
                                    local.get $k02_r
                                    local.set $peso_r
                                    local.get $k02_g
                                    local.set $peso_g
                                    local.get $k02_b
                                    local.set $peso_b
                                    br $end
                                  )
                                  ;; $k10
                                  local.get $k10_r
                                  local.set $peso_r
                                  local.get $k10_g
                                  local.set $peso_g
                                  local.get $k10_b
                                  local.set $peso_b
                                  br $end
                                )
                                ;; $k11
                                local.get $k11_r
                                local.set $peso_r
                                local.get $k11_g
                                local.set $peso_g
                                local.get $k11_b
                                local.set $peso_b
                                br $end
                              )
                              ;; $k12
                              local.get $k12_r
                              local.set $peso_r
                              local.get $k12_g
                              local.set $peso_g
                              local.get $k12_b
                              local.set $peso_b
                              br $end
                            )
                            ;; $k20
                            local.get $k20_r
                            local.set $peso_r
                            local.get $k20_g
                            local.set $peso_g
                            local.get $k20_b
                            local.set $peso_b
                            br $end
                          )
                          ;; $k21
                          local.get $k21_r
                          local.set $peso_r
                          local.get $k21_g
                          local.set $peso_g
                          local.get $k21_b
                          local.set $peso_b
                          br $end
                        )
                        ;; $k22
                        local.get $k22_r
                        local.set $peso_r
                        local.get $k22_g
                        local.set $peso_g
                        local.get $k22_b
                        local.set $peso_b
                        br $end
                      )
                      ;; $default
                      f32.const 0
                      local.set $peso_r
                      f32.const 0
                      local.set $peso_g
                      f32.const 0
                      local.set $peso_b
                    )

                    ;; RED
                    ;; sum += r * peso_r
                    local.get $sum_r
                    local.get $r
                    local.get $peso_r
                    f32.mul
                    f32.add
                    local.set $sum_r

                    ;; GREEN
                    ;; sum += g * peso_g
                    local.get $sum_g
                    local.get $g
                    local.get $peso_g
                    f32.mul
                    f32.add
                    local.set $sum_g

                    ;; BLUE
                    ;; sum += b * peso_b
                    local.get $sum_b
                    local.get $b
                    local.get $peso_b
                    f32.mul
                    f32.add
                    local.set $sum_b

                    ;; advance kj
                    local.get $kj
                    i32.const 1
                    i32.add
                    local.tee $kj
                    local.get $kw_len
                    ;;i32.const 3  ;; alterar para 2 3 5 7 dependendo do tamanho do kernel
                    i32.lt_s

                    br_if $loop_kj
                  end  ;; end of kernel horizontal loop (kj)
                end  ;; end of kernel horizontal loop (kj)

                ;; avança ki
                local.get $ki
                i32.const 1
                i32.add
                local.tee $ki
                local.get $kh_len
                ;;i32.const 3  ;; alterar para 2 3 5 7 dependendo do tamanho do kernel
                i32.lt_s
                br_if $loop_ki
              end ;; end of kernel vertical loop (ki)
            end ;; end of kernel vertical loop (ki)

            local.get $sum_r
            local.get $sum_g
            local.get $sum_b
            f32.add
            f32.add
            local.set $sum

            ;; 9) escreve saída: out[(i_out*out_w + j_out)*4] = sum
            local.get $out ;; 16
            local.get $i_out ;; 0
            local.get $out_w ;; 4
            i32.mul
            local.get $j_out ;; 0
            i32.add ;; 0
            i32.const 4
            i32.mul
            i32.add         ;; indice
            local.get $sum  ;; valor
            f32.store

            ;; avança j_out
            local.get $j_out
            i32.const 1
            i32.add
            local.tee $j_out
            local.get $out_w
            i32.lt_s
            br_if $inner
          end 
        end

        ;; avança i_out
        local.get $i_out
        i32.const 1
        i32.add
        local.tee $i_out
        local.get $out_h
        i32.lt_s
        br_if $outer
      end
    end
  )

  (func $extract_rgb_f32 (param $pixel_bytes_16bits i32) (result f32) (result f32) (result f32)
    (local $red i32)
    (local $green i32)
    (local $blue i32)

    (local $red_f32 f32)
    (local $green_f32 f32)
    (local $blue_f32 f32)

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
    f32.convert_i32_u
    local.set $blue_f32

    local.get $green
    f32.convert_i32_u
    local.set $green_f32

    local.get $red
    f32.convert_i32_u
    local.set $red_f32

    local.get $blue_f32
    local.get $green_f32
    local.get $red_f32
  )
  ;; Export the function so it can be called from outside
  (export "convolve_rgb565_3x3_valid_first_layer" (func $convolve_rgb565_3x3_valid_first_layer))
  (export "extract_rgb_f32" (func $extract_rgb_f32))
)

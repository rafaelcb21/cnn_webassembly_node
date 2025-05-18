(module
  ;; Export a linear memory of at least 1 page (64KiB)
  (memory (export "memory") 1)

  ;; convolve function signature:
  ;; (param $img i32)       – pointer to first element of input image (i32 array)
  ;; (param $h i32)         – height of the real image
  ;; (param $w i32)         – width of the real image
  ;; (param $ker i32)       – pointer to first element of kernel (i32 array)
  ;; (param $kh i32)        – kernel height
  ;; (param $kw i32)        – kernel width
  ;; (param $pad_t i32)     – top padding
  ;; (param $pad_b i32)     – bottom padding
  ;; (param $pad_l i32)     – left padding
  ;; (param $pad_r i32)     – right padding
  ;; (param $stride_h i32)  – vertical stride
  ;; (param $stride_w i32)  – horizontal stride
  ;; (param $out i32)       – pointer to first element of output buffer (i32 array)

  (func $convolve
    (param $img      i32) (param $h      i32) (param $w      i32)
    (param $ker      i32) (param $kh     i32) (param $kw     i32)
    (param $pad_t    i32) (param $pad_b  i32) (param $pad_l  i32) 
    (param $pad_r    i32) (param $stride_h i32) (param $stride_w i32) (param $out   i32)

    (local $ht      i32) (local $wt       i32)
    (local $out_h   i32) (local $out_w    i32)
    (local $i_out   i32) (local $j_out    i32)
    (local $i       i32) (local $j         i32)
    (local $sum     i32) (local $ki        i32) (local $kj i32)
    (local $row     i32) (local $col       i32)
    (local $row_img i32) (local $col_img   i32) (local $row_base i32)
    (local $idx     i32) (local $val       i32) (local $peso i32)

    ;; ht = pad_t + h + pad_b
    local.get $pad_t
    local.get $h
    i32.add
    local.get $pad_b
    i32.add
    local.set $ht

    ;; wt = pad_l + w + pad_r
    local.get $pad_l
    local.get $w
    i32.add
    local.get $pad_r
    i32.add
    local.set $wt

    ;; out_h = ((ht - kh) / stride_h) + 1
    local.get $ht
    local.get $kh
    i32.sub
    local.get $stride_h
    i32.div_s
    i32.const 1
    i32.add
    local.set $out_h

    ;; out_w = ((wt - kw) / stride_w) + 1
    local.get $wt
    local.get $kw
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
      loop $outer
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
            i32.const 0
            local.set $sum

            ;; --- Kernel vertical loop (ki) ---
            i32.const 0
            local.set $ki
            block $break_ki
              loop $loop_ki
                ;; row = i + ki
                local.get $i
                local.get $ki
                i32.add
                local.tee $row

                ;; skip if outside padded image vertically
                local.get $row
                local.get $pad_t
                i32.lt_s
                br_if $loop_ki
                local.get $row
                local.get $pad_t
                local.get $h
                i32.add
                i32.ge_s
                br_if $loop_ki

                ;; compute row_img and row_base
                local.get $row
                local.get $pad_t
                i32.sub
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
                    local.tee $col

                    ;; skip if outside padded image horizontally
                    local.get $col
                    local.get $pad_l
                    i32.lt_s
                    br_if $loop_kj
                    local.get $col
                    local.get $pad_l
                    local.get $w
                    i32.add
                    i32.ge_s
                    br_if $loop_kj

                    ;; compute col_img and idx
                    local.get $col
                    local.get $pad_l
                    i32.sub
                    local.set $col_img
                    local.get $row_base
                    local.get $col_img
                    i32.add
                    local.set $idx

                    ;; val = load image[idx]
                    local.get $img
                    local.get $idx
                    i32.const 4
                    i32.mul
                    i32.add
                    i32.load
                    local.set $val

                    ;; peso = load kernel[ki*kw + kj]
                    local.get $ker
                    local.get $ki
                    local.get $kw
                    i32.mul
                    local.get $kj
                    i32.add
                    i32.const 4
                    i32.mul
                    i32.add
                    i32.load
                    local.set $peso

                    ;; sum += val * peso
                    local.get $sum
                    local.get $val
                    local.get $peso
                    i32.mul
                    i32.add
                    local.set $sum

                    ;; advance kj
                    local.get $kj
                    i32.const 1
                    i32.add
                    local.tee $kj
                    local.get $kw
                    i32.lt_s
                    br_if $loop_kj
                  end
                end

                ;; advance ki
                local.get $ki
                i32.const 1
                i32.add
                local.tee $ki
                local.get $kh
                i32.lt_s
                br_if $loop_ki
              end
            end

            ;; store the computed sum into output[(i_out*out_w + j_out)]
            local.get $out
            local.get $i_out
            local.get $out_w
            i32.mul
            local.get $j_out
            i32.add
            i32.const 4
            i32.mul
            i32.add
            local.get $sum
            i32.store

            ;; advance j_out
            local.get $j_out
            i32.const 1
            i32.add
            local.tee $j_out
            local.get $out_w
            i32.lt_s
            br_if $inner
          end
        end

        ;; advance i_out
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

  ;; ————————————————————————————————————————
  ;; Definição dos 4 elementos do kernel como globals imutáveis
  ;; (substitua os valores abaixo pelos seus)
  (global $k00 i32 (i32.const 2))    ;; kernel[0*2 + 0]
  (global $k01 i32 (i32.const -4))   ;; kernel[0*2 + 1]
  (global $k10 i32 (i32.const 1))    ;; kernel[1*2 + 0]
  (global $k11 i32 (i32.const 3))    ;; kernel[1*2 + 1]
  ;; ————————————————————————————————————————

  (func $convolve2
    (param $img       i32)  ;; ptr para imagem
    (param $h         i32)
    (param $w         i32)
    ;; não há mais parâmetro $ker
    (param $kh        i32)  ;; =2
    (param $kw        i32)  ;; =2
    (param $pad_t     i32)
    (param $pad_b     i32)
    (param $pad_l     i32)
    (param $pad_r     i32)
    (param $stride_h  i32)
    (param $stride_w  i32)
    (param $out       i32)  ;; ptr de saída
    (param $format    i32)  ;; 0 = grayscale, 1 = rgb565
    (param $k00       i32)  ;; value of kernel by index 00
    (param $k01       i32)  ;; value of kernel by index 01
    (param $k02       i32)  ;; value of kernel by index 02
    (param $k10       i32)  ;; value of kernel by index 10
    (param $k11       i32)  ;; value of kernel by index 11
    (param $k12       i32)  ;; value of kernel by index 12
    (param $k20       i32)  ;; value of kernel by index 20
    (param $k21       i32)  ;; value of kernel by index 21
    (param $k22       i32)  ;; value of kernel by index 22

    (local $out_h     i32) (local $out_w    i32)
    (local $ht        i32) (local $wt       i32)
    (local $i_out     i32) (local $j_out    i32)
    (local $i         i32) (local $j        i32)
    (local $ki        i32) (local $kj       i32)
    (local $row       i32) (local $col      i32)
    (local $row_img   i32) (local $col_img  i32) 
    (local $row_base  i32) (local $idx  i32) 
    (local $val       i32) (local $sum      i32) 
    (local $idx_ker   i32) (local $peso     i32)
    (local $r         i32)
    (local $g         i32)
    (local $b         i32)
    

    ;; ht = pad_t + h + pad_b
    local.get $pad_t
    local.get $h
    i32.add
    local.get $pad_b
    i32.add
    local.set $ht

    ;; wt = pad_l + w + pad_r
    local.get $pad_l
    local.get $w
    i32.add
    local.get $pad_r
    i32.add
    local.set $wt

    ;; out_h = ((ht - kh) / stride_h) + 1
    local.get $ht
    local.get $kh
    i32.sub
    local.get $stride_h
    i32.div_s
    i32.const 1
    i32.add
    local.set $out_h

    ;; out_w = ((wt - kw) / stride_w) + 1
    local.get $wt
    local.get $kw
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
            i32.const 0
            local.set $sum

            ;; --- Kernel vertical loop (ki) ---
            i32.const 0
            local.set $ki
            block $break_ki
              loop $loop_ki
                ;; row = i + ki
                local.get $i
                local.get $ki
                i32.add
                local.tee $row

                ;; skip if outside padded image vertically
                ;; pad_top <= row < pad_top + height_real
                local.get $row
                local.get $pad_t
                i32.lt_s          ;; row < pad_t
                br_if $loop_ki
                local.get $row
                local.get $pad_t
                local.get $h
                i32.add
                i32.ge_s          ;; row >= pad_t + h
                br_if $loop_ki

                ;; compute row_img and row_base
                local.get $row
                local.get $pad_t
                i32.sub
                local.set $row_img
                local.get $row_img
                local.get $w
                i32.mul
                local.set $row_base

                ;; --- Kernel horizontal loop (kj) ---
                i32.const 0
                local.set $kj
                loop $loop_kj
                  ;; col = j + kj
                  local.get $j
                  local.get $kj
                  i32.add
                  local.tee $col

                  ;; skip if outside padded image horizontally
                  local.get $col
                  local.get $pad_l
                  i32.lt_s
                  br_if $loop_kj
                  local.get $col
                  local.get $pad_l
                  local.get $w
                  i32.add
                  i32.ge_s
                  br_if $loop_kj

                  ;; compute col_img and idx
                  local.get $col
                  local.get $pad_l
                  i32.sub
                  local.set $col_img
                  local.get $row_base
                  local.get $col_img
                  i32.add
                  local.set $idx

                  ;; val = load image[idx]
                  local.get $format
                  i32.const 0
                  i32.eq
                  if  ;; ----- Grayscale (1 byte por pixel) -----
                    ;; endereço = base_img + idx*1
                    local.get $img
                    local.get $idx
                    i32.add
                    ;; carrega 1 byte e faz zero-extend
                    i32.load8_u
                    local.set $val

                    ;; ki * kernel_w + kj
                    local.get $ki
                    local.get $kw
                    i32.mul
                    local.get $kj
                    i32.add
                    local.tee $idx_ker

                    (block $end
                      (block $fallback
                        (block $k22
                          (block $k21
                            (block $k20
                              (block $k12
                                (block $k11
                                  (block $k10
                                    (block $k02
                                      (block $k01
                                        (block $k00
                                          ;; Despacho do índice
                                          local.get $idx_ker
                                          br_table $k00 $k01 $k02
                                                  $k10 $k11 $k12
                                                  $k20 $k21 $k22
                                                  $fallback
                                        )
                                        ;; $k00
                                        local.get $k00
                                        local.set $peso
                                        br $end
                                      )
                                      ;; $k01
                                      local.get $k01
                                      local.set $peso
                                      br $end
                                    )
                                    ;; $k02
                                    local.get $k02
                                    local.set $peso
                                    br $end
                                  )
                                  ;; $k10
                                  local.get $k10
                                  local.set $peso
                                  br $end
                                )
                                ;; $k11
                                local.get $k11
                                local.set $peso
                                br $end
                              )
                              ;; $k12
                              local.get $k12
                              local.set $peso
                              br $end
                            )
                            ;; $k20
                            local.get $k20
                            local.set $peso
                            br $end
                          )
                          ;; $k21
                          local.get $k21
                          local.set $peso
                          br $end
                        )
                        ;; $k22
                        local.get $k22
                        local.set $peso
                        br $end
                      )
                      ;; fallback
                      i32.const 0
                      local.set $peso
                    )

                    ;; sum += val * peso
                    local.get $sum
                    local.get $val
                    local.get $peso
                    i32.mul
                    i32.add
                    local.set $sum

                    ;; advance kj
                    local.get $kj
                    i32.const 1
                    i32.add
                    local.tee $kj
                    local.get $kw
                    i32.lt_s
                    br_if $loop_kj

                  else  ;; rgb565 branch
                    ;; endereço = base_img + idx*2
                    ;; fazer DEPOIS
                    local.get $img
                    local.get $idx
                    i32.const 2
                    i32.mul
                    i32.add
                    ;; carrega 2 bytes e faz zero-extend
                    i32.load16_u
                    local.tee $val  ;; aqui $val contém o valor RGB565 completo (você pode extrair R/G/B depois)
                    call $extract_rgb
                    local.set $r
                    local.set $g
                    local.set $b

                    ;; ki * kernel_w + kj
                    local.get $ki
                    local.get $kw
                    i32.mul
                    local.get $kj
                    i32.add
                    local.tee $idx_ker
                  end
                end
              end
            end
          end
        end
      end
    end
  )
  (func $extract_rgb (param $pixel_bytes_16bits i32) (result i32) (result i32) (result i32)
    (local $red i32)
    (local $green_1 i32)
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
    ;; Red
    ;; Green
    ;; Blue
    local.get $blue
    local.get $green
    local.get $red
  )
  


  ;; Export the function so it can be called from outside
  (export "convolve" (func $convolve))
)

(local $peso i32)         ;; peso final selecionado
(local $idx_ker i32)      ;; índice do kernel a acessar

;;(block $end
;;  (block $fallback
;;    (block $k44
;;      (block $k43
;;        (block $k42
;;          (block $k41
;;            (block $k40
;;              (block $k34
;;                (block $k33
;;                  (block $k32
;;                    (block $k31
;;                      (block $k30
;;                        (block $k24
;;                          (block $k23
;;                            (block $k22
;;                              (block $k21
;;                                (block $k20
;;                                  (block $k14
;;                                    (block $k13
;;                                      (block $k12
;;                                        (block $k11
;;                                          (block $k10
;;                                            (block $k04
;;                                              (block $k03
;;                                                (block $k02
;;                                                  (block $k01
;;                                                    (block $k00
;;                                                      ;; Despacho
;;                                                      local.get $idx_ker
;;                                                      br_table $k00 $k01 $k02 $k03 $k04
;;                                                               $k10 $k11 $k12 $k13 $k14
;;                                                               $k20 $k21 $k22 $k23 $k24
;;                                                               $k30 $k31 $k32 $k33 $k34
;;                                                               $k40 $k41 $k42 $k43 $k44
;;                                                               $fallback
;;                                                    )
;;                                                    ;; $k00
;;                                                    global.get $k00
;;                                                    local.set $peso
;;                                                    br $end
;;                                                  )
;;                                                  ;; $k01
;;                                                  global.get $k01
;;                                                  local.set $peso
;;                                                  br $end
;;                                                )
;;                                                ;; $k02
;;                                                global.get $k02
;;                                                local.set $peso
;;                                                br $end
;;                                              )
;;                                              ;; $k03
;;                                              global.get $k03
;;                                              local.set $peso
;;                                              br $end
;;                                            )
;;                                            ;; $k04
;;                                            global.get $k04
;;                                            local.set $peso
;;                                            br $end
;;                                          )
;;                                          ;; $k10
;;                                          global.get $k10
;;                                          local.set $peso
;;                                          br $end
;;                                        )
;;                                        ;; $k11
;;                                        global.get $k11
;;                                        local.set $peso
;;                                        br $end
;;                                      )
;;                                      ;; $k12
;;                                      global.get $k12
;;                                      local.set $peso
;;                                      br $end
;;                                    )
;;                                    ;; $k13
;;                                    global.get $k13
;;                                    local.set $peso
;;                                    br $end
;;                                  )
;;                                  ;; $k14
;;                                  global.get $k14
;;                                  local.set $peso
;;                                  br $end
;;                                )
;;                                ;; $k20
;;                                global.get $k20
;;                                local.set $peso
;;                                br $end
;;                              )
;;                              ;; $k21
;;                              global.get $k21
;;                              local.set $peso
;;                              br $end
;;                            )
;;                            ;; $k22
;;                            global.get $k22
;;                            local.set $peso
;;                            br $end
;;                          )
;;                          ;; $k23
;;                          global.get $k23
;;                          local.set $peso
;;                          br $end
;;                        )
;;                        ;; $k24
;;                        global.get $k24
;;                        local.set $peso
;;                        br $end
;;                      )
;;                      ;; $k30
;;                      global.get $k30
;;                      local.set $peso
;;                      br $end
;;                    )
;;                    ;; $k31
;;                    global.get $k31
;;                    local.set $peso
;;                    br $end
;;                  )
;;                  ;; $k32
;;                  global.get $k32
;;                  local.set $peso
;;                  br $end
;;                )
;;                ;; $k33
;;                global.get $k33
;;                local.set $peso
;;                br $end
;;              )
;;              ;; $k34
;;              global.get $k34
;;              local.set $peso
;;              br $end
;;            )
;;            ;; $k40
;;            global.get $k40
;;            local.set $peso
;;            br $end
;;          )
;;          ;; $k41
;;          global.get $k41
;;          local.set $peso
;;          br $end
;;        )
;;        ;; $k42
;;        global.get $k42
;;        local.set $peso
;;        br $end
;;      )
;;      ;; $k43
;;      global.get $k43
;;      local.set $peso
;;      br $end
;;    )
;;    ;; $k44
;;    global.get $k44
;;    local.set $peso
;;    br $end
;;  )
;;  ;; fallback
;;  i32.const 0
;;  local.set $peso
;;)

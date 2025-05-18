(module
  ;; Export a linear memory of at least 1 page (64KiB)
  (memory (export "memory") 1)

  ;; convolve function signature:
  ;; (param $img i32)       – pointer to first element of input image (i32 array)
  ;; (param $h i32)         – height of the real image
  ;; (param $w i32)         – width of the real image
  ;; (param $ker i32)       – pointer to first element of kernel (i32 array)
  ;; (param $pad_t i32)     – top padding
  ;; (param $pad_b i32)     – bottom padding
  ;; (param $pad_l i32)     – left padding
  ;; (param $pad_r i32)     – right padding
  ;; (param $stride_h i32)  – vertical stride
  ;; (param $stride_w i32)  – horizontal stride
  ;; (param $out i32)       – pointer to first element of output buffer (i32 array)

  (func $convolve_3x3_grayscale
    (param $img       i32)  ;; ptr para imagem
    (param $h         i32)
    (param $w         i32)
    (param $pad_t     i32)
    (param $pad_b     i32)
    (param $pad_l     i32)
    (param $pad_r     i32)
    (param $stride_h  i32)
    (param $stride_w  i32)
    (param $out       i32)  ;; ptr de saída
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
    i32.const 3  ;; alterar para 2 3 5 7 dependendo do tamanho do kernel
    i32.sub
    local.get $stride_h
    i32.div_s
    i32.const 1
    i32.add
    local.set $out_h

    ;; out_w = ((wt - kw) / stride_w) + 1
    local.get $wt
    i32.const 3  ;; alterar para 2 3 5 7 dependendo do tamanho do kernel
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

                    ;; ----- Grayscale (1 byte por pixel) -----
                    ;; endereço = base_img + idx*1
                    local.get $img
                    local.get $idx
                    i32.add
                    ;; carrega 1 byte e faz zero-extend
                    i32.load8_u ;; alterar para i32.load16_u se for RGB565
                    local.set $val

                    ;; ki * kernel_w + kj
                    local.get $ki
                    i32.const 3  ;; alterar para 2 3 5 7 dependendo do tamanho do kernel
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
                                          br_table $k00 $k01 $k02
                                                  $k10 $k11 $k12
                                                  $k20 $k21 $k22
                                                  $default
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
                      ;; fallback default
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
                    i32.const 3  ;; alterar para 2 3 5 7 dependendo do tamanho do kernel
                    i32.lt_s
                    br_if $loop_kj
                    drop
                  end  ;; end of kernel horizontal loop (kj)
                end  ;; end of kernel horizontal loop (kj)

                ;; avança ki
                local.get $ki
                i32.const 1
                i32.add
                local.tee $ki
                i32.const 3  ;; alterar para 2 3 5 7 dependendo do tamanho do kernel
                i32.lt_s
                br_if $loop_ki
                drop
              end ;; end of kernel vertical loop (ki)
            end ;; end of kernel vertical loop (ki)

            ;; 9) escreve saída: out[(i_out*out_w + j_out)*4] = sum
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
  ;; Export the function so it can be called from outside
  (export "convolve_3x3_grayscale" (func $convolve_3x3_grayscale))
)

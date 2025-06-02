def convolve_apply_kernel(imagem_real, height_real, width_real,
                                kernel, kernel_h, kernel_w,
                                pad_top, pad_bottom, pad_left, pad_right,
                                stride_h, stride_w):

    height_total = pad_top + height_real + pad_bottom
    width_total = pad_left + width_real + pad_right

    out_h = ((height_total - kernel_h) // stride_h) + 1
    out_w = ((width_total - kernel_w) // stride_w) + 1

    resultado = []

    for i_out in range(out_h):
        linha_resultado = []
        i = i_out * stride_h
        print('i = i_out * stride_h', i, i_out, stride_h)
        for j_out in range(out_w):
            j = j_out * stride_w
            print('j = j_out * stride_w', j, j_out, stride_w)
            soma = 0

            for ki in range(kernel_h):
                row = i + ki
                print('row = i + ki', row, i, ki)
                print('pad_top <= row < pad_top + height_real', pad_top, row, pad_top + height_real, pad_top <= row < pad_top + height_real)
                if not (pad_top <= row < pad_top + height_real):
                    print('continue top')
                    continue  # pula a linha do kernel fora da imagem

                row_img = row - pad_top
                print('row_img = row - pad_top', row_img, row, pad_top)
                row_base = row_img * width_real
                print('row_base = row_img * width_real', row_base, row_img, width_real)
                for kj in range(kernel_w):
                    col = j + kj
                    print('col = j + kj', col, j, kj)
                    print('pad_left <= col < pad_left + width_real', pad_left, col, pad_left + width_real, pad_left <= col < pad_left + width_real)
                    if not (pad_left <= col < pad_left + width_real):
                        print('continue left')
                        continue  # pula coluna fora da imagem

                    col_img = col - pad_left
                    print('col_img = col - pad_left', col_img, col, pad_left)
                    idx = row_base + col_img
                    print('idx = row_base + col_img', idx, row_base, col_img)
                    val = imagem_real[idx]
                    print('val = imagem_real[idx]', val)
                    peso = kernel[ki * kernel_w + kj]
                    print('peso = kernel[ki * kernel_w + kj]', peso, ki, kernel_w, kj, ki * kernel_w + kj, ' = ',kernel[ki * kernel_w + kj])
                    soma += val * peso
                    print('soma += val * peso', soma, val, peso)
                    print('-----------------------------------------')
            print('soma final', soma)
            print('====================================')

            linha_resultado.append(soma)
        resultado.append(linha_resultado)

    return resultado

# Imagem 4x4 (linearizada)
imagem = [
     1, 5, 8, 12, 
     16, 20, 23, 27, 
     31, 26, 22, 18, 
     15, 11, 7, 3
]

# Kernel 3×3: detector de borda simples
kernel = [
    0.2, -0.4, 0.2,
    0.1,  0.3, 0.7,
    0.5,  0.2, 0.1
]

# Aplicar convolução com padding = 1 (para manter tamanho), stride = 1
saida = convolve_apply_kernel(
    imagem_real = imagem,
    height_real = 4,
    width_real = 4,
    kernel = kernel,
    kernel_h = 3,
    kernel_w = 3,
    pad_top = 1,
    pad_bottom = 1,
    pad_left = 1,
    pad_right = 1,
    stride_h = 1,
    stride_w = 1
)

# Mostrar resultado
print("Resultado final da convolução:")
for linha in saida:
    print(linha)

#1x1
#[9.0, 21.5, 28.599999999999998, 21.299999999999997]
#[28.2, 46.400000000000006, 47.199999999999996, 21.8]
#[29.2, 36.50000000000001, 29.2, 5.5]
#[4.999999999999999, 9.899999999999999, 5.299999999999999, -1.1999999999999997]


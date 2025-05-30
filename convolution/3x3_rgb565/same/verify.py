def convolve_rgb(imagem_rgb, height_real, width_real,
                 kernel_r, kernel_g, kernel_b,
                 kernel_h, kernel_w,
                 pad_top, pad_bottom, pad_left, pad_right,
                 stride_h, stride_w):

    height_total = pad_top + height_real + pad_bottom
    width_total = pad_left + width_real + pad_right

    out_h = ((height_total - kernel_h) // stride_h) + 1
    out_w = ((width_total - kernel_w) // stride_w) + 1

    resultado = []
    #print(out_h, height_total, kernel_h, stride_h, (height_total - kernel_h) // stride_h)
    for i_out in range(out_h):
        linha_resultado = []
        i = i_out * stride_h
        print('>>> ',i, i_out, stride_h)
        for j_out in range(out_w):
            j = j_out * stride_w

            soma = 0  # resultado final da soma R + G + B

            for ki in range(kernel_h): # vai para o lado
                row = i + ki
                print(pad_top, row, pad_top + height_real, i, j, ki)
                if not (pad_top <= row < pad_top + height_real):
                    print('continue')
                    continue

                row_img = row - pad_top
                row_base = row_img * width_real

                for kj in range(kernel_w):
                    col = j + kj
                    if not (pad_left <= col < pad_left + width_real):
                        continue

                    col_img = col - pad_left
                    idx = row_base + col_img
                    pixel = imagem_rgb[idx]  # pixel é uma tupla (R, G, B)

                    # Aplicar os 3 kernels
                    k_idx = ki * kernel_w + kj
                    soma_r = pixel[0] * kernel_r[k_idx]
                    soma_g = pixel[1] * kernel_g[k_idx]
                    soma_b = pixel[2] * kernel_b[k_idx]

                    soma += soma_r + soma_g + soma_b

            linha_resultado.append(soma)
        resultado.append(linha_resultado)

    return resultado


# Imagem 4x4 (linearizada)
# Imagem 4x4 RGB
imagem = [ 
    (1, 5, 3), (5, 12, 7), (8, 20, 11), (12, 27, 15),
    (16, 35, 18), (20, 42, 22), (23, 50, 26), (27, 57, 30),
    (31, 60, 28), (26, 50, 23), (22, 42, 20), (18, 35, 16),
    (15, 27, 12), (11, 20, 8), (7, 12, 5), (3, 5, 1)
]

# Kernels para R, G e B 3x3
kernel_r = [2, -4, 2, 1, 3, 7, 5 , 2 , 1]
kernel_g = [3, 2, 4, 1, 4, 2, 9, 8, 5]
kernel_b = [7, 2, 4, 1, 5, 7, 2, 3, 9]

# saida 3x3
saida = convolve_rgb(
    imagem_rgb = imagem,
    height_real = 4,
    width_real = 4,
    kernel_r = kernel_r,
    kernel_g = kernel_g,
    kernel_b = kernel_b,
    kernel_h = 3,
    kernel_w = 3,
    pad_top = 1,
    pad_bottom = 1,
    pad_left = 1,
    pad_right = 1,
    stride_h = 2,
    stride_w = 1
)

# Mostrar resultado
print("Resultado final da convolução RGB somada:")
for linha in saida:
    print(linha)

#1x1
#[940, 1660, 2054, 1475]
#[1863, 2730, 2716, 1639]
#[1719, 2211, 1936, 1004]
#[782, 1087, 810, 398]

#2x2
#[940, 2054]
#[1719, 1936]

#1x2
#[940, 2054]
#[1863, 2716]
#[1719, 1936]
#[782, 810]

#2x1
#[940, 1660, 2054, 1475]
#[1719, 2211, 1936, 1004]

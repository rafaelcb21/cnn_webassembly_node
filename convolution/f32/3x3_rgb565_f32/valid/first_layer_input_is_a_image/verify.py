def convolve_rgb_valid(imagem_rgb, height, width,
                       kernel_r, kernel_g, kernel_b,
                       kernel_h, kernel_w,
                       stride_h, stride_w):
    # Cálculo das dimensões de saída (valid)
    out_h = ((height - kernel_h) // stride_h) + 1
    out_w = ((width - kernel_w) // stride_w) + 1

    resultado = []
    for i_out in range(out_h):
        row0 = i_out * stride_h
        linha = []
        for j_out in range(out_w):
            col0 = j_out * stride_w
            soma = 0
            # Varre o kernel sobre a imagem, sem checagem de padding
            for ki in range(kernel_h):
                for kj in range(kernel_w):
                    idx = (row0 + ki) * width + (col0 + kj)
                    r, g, b = imagem_rgb[idx]
                    kidx = ki * kernel_w + kj
                    soma += (
                        r * kernel_r[kidx] +
                        g * kernel_g[kidx] +
                        b * kernel_b[kidx]
                    )
            linha.append(soma)
        resultado.append(linha)

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
kernel_r = [0.2, -0.4, 0.2, 0.1, 0.3, 0.7, 0.5 , 0.2 , 0.1]
kernel_g = [0.3, 0.2, 0.4, 0.1, 0.4, 0.2, 0.9, 0.8, 0.5]
kernel_b = [0.7, 0.2, 0.4, 0.1, 0.5, 0.7, 0.2, 0.3, 0.9]

# saida 3x3
saida = convolve_rgb_valid(
    imagem_rgb = imagem,
    height = 4,
    width = 4,
    kernel_r = kernel_r,
    kernel_g = kernel_g,
    kernel_b = kernel_b,
    kernel_h = 3,
    kernel_w = 3,
    stride_h = 1,
    stride_w = 1
)

# Mostrar resultado
print("Resultado final da convolução RGB somada:")
for linha in saida:
    print(linha)

#1x1
#[273.0, 271.6]
#[221.1, 193.6]
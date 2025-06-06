def convolve_rgb_valid(imagem, height, width,
                       kernel,
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
                    gray = imagem[idx]
                    kidx = ki * kernel_w + kj
                    soma += (
                        gray * kernel[kidx]
                    )
            linha.append(soma)
        resultado.append(linha)

    return resultado

# Imagem 4x4 (linearizada)
# Imagem 4x4 RGB
imagem = [
     1, 5, 8, 12, 
     16, 20, 23, 27, 
     31, 26, 22, 18, 
     15, 11, 7, 3
]

# Kernels para Grayscale
kernel = [
    0.2, -0.4, 0.2,
    0.1,  0.3, 0.7,
    0.5,  0.2, 0.1
]

# saida 3x3
saida = convolve_rgb_valid(
    imagem = imagem,
    height = 4,
    width = 4,
    kernel = kernel,
    kernel_h = 3,
    kernel_w = 3,
    stride_h = 1,
    stride_w = 1
)

# Mostrar resultado
print("Resultado final da convolução RGB somada:")
for linha in saida:
    print(linha)

# stride 1x1
#[46.400000000000006, 47.199999999999996]
#[36.50000000000001, 29.2]


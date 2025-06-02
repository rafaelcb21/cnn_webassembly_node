import math

def convolve_gray_1x1(imagem_gray, height, width, weight, stride_h=1, stride_w=1):
    """
    Convolução 1×1 para imagem em tons de cinza, com strides:
      - imagem_gray: lista linearizada de valores [0…255]
      - height, width: dimensões da imagem
      - weight: peso do kernel 1×1
      - stride_h, stride_w: deslocamento vertical e horizontal
    """
    # Calcula quantas posições “valid” cabem
    out_h = ((height  - 1) // stride_h) + 1
    out_w = ((width   - 1) // stride_w) + 1

    resultado = []
    for i_out in range(out_h):
        i = i_out * stride_h
        linha = []
        for j_out in range(out_w):
            j = j_out * stride_w
            idx   = i * width + j
            pixel = imagem_gray[idx]
            # Aplica o kernel 1×1 (multiplica o pixel pelo peso)
            valor = pixel * weight
            linha.append(valor)
        resultado.append(linha)

    return resultado

# --- Teste com a imagem 4×4 de exemplo ---
imagem_gray = [
     1,  5,  8, 12,
    16, 20, 23, 27,
    31, 26, 22, 18,
    15, 11,  7,  3
]

weight = 2

for stride_h, stride_w in [(1,1), (2,2), (2,1), (1,2)]:
    saida = convolve_gray_1x1(
        imagem_gray, height=4, width=4,
        weight=weight,
        stride_h=stride_h, stride_w=stride_w
    )
    print(f"\nstride=({stride_h}×{stride_w}), saída {len(saida)}×{len(saida[0])}:")
    for linha in saida:
        print(linha)

#stride=(1×1), saída 4×4:
#[2, 10, 16, 24]
#[32, 40, 46, 54]
#[62, 52, 44, 36]
#[30, 22, 14, 6]

#stride=(2×2), saída 2×2:
#[2, 16]
#[62, 44]

#stride=(1×2), saída 4×2:
#[2, 16]
#[32, 46]
#[62, 44]
#[30, 14]

#stride=(2×1), saída 2×4:
#[2, 10, 16, 24]
#[62, 52, 44, 36]
#
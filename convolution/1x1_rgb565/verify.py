def convolve_rgb_1x1(imagem_rgb, height, width,
                     weight_r, weight_g, weight_b,
                     stride_h=1, stride_w=1):
    """
    Convolução 1×1 para imagem RGB, sem padding, com strides:
      - imagem_rgb: lista linearizada de tuplas (R, G, B)
      - height, width: dimensões da imagem
      - weight_r, weight_g, weight_b: pesos do kernel 1×1 por canal
      - stride_h, stride_w: deslocamento vertical e horizontal
    """
    # Quantas posições “valid” cabem em cada dimensão
    out_h = ((height - 1) // stride_h) + 1
    out_w = ((width  - 1) // stride_w) + 1

    resultado = []
    for i_out in range(out_h):
        i = i_out * stride_h
        linha = []
        for j_out in range(out_w):
            j = j_out * stride_w
            idx = i * width + j
            r, g, b = imagem_rgb[idx]
            soma = r * weight_r + g * weight_g + b * weight_b
            linha.append(soma)
        resultado.append(linha)

    return resultado


# --- Exemplo de uso sobre a mesma imagem 4×4 RGB de antes ---
imagem = [
    (1, 5, 3),   (5, 12, 7),  (8, 20, 11), (12, 27, 15),
    (16,35,18),  (20,42,22),  (23,50,26),  (27,57,30),
    (31,60,28),  (26,50,23),  (22,42,20),  (18,35,16),
    (15,27,12),  (11,20,8),   (7,12,5),    (3,5,1)
]
weight_r, weight_g, weight_b = 2, 3, 4

for stride_h, stride_w in [(1,1), (2,2), (2,1), (1,2)]:
    saida = convolve_rgb_1x1(
        imagem, height=4, width=4,
        weight_r=weight_r, weight_g=weight_g, weight_b=weight_b,
        stride_h=stride_h, stride_w=stride_w
    )
    print(f"\nstride=({stride_h}×{stride_w}), saída {len(saida)}×{len(saida[0])}:")
    for linha in saida:
        print(linha)

#stride=(1×1), saída 4×4:
#[29, 74, 120, 165]
#[209, 254, 300, 345]
#[354, 294, 250, 205]
#[159, 114, 70, 25]

#stride=(2×2), saída 2×2:
#[29, 120]
#[354, 250]

#stride=(1×2), saída 4×2:
#[29, 120]
#[209, 300]
#[354, 250]
#[159, 70]

#stride=(2×1), saída 2×4:
#[29, 74, 120, 165]
#[354, 294, 250, 205]


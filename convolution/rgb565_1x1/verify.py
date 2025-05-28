def convolve_rgb_1x1(imagem_rgb, height, width, weight_r, weight_g, weight_b):
    """
    Convolução 1x1 sem padding:
      - imagem_rgb: lista linearizada de tuplas (R, G, B)
      - height, width: dimensões da imagem
      - weight_r, weight_g, weight_b: pesos do kernel 1x1 para cada canal
    """
    resultado = []
    for i in range(height):
        linha = []
        for j in range(width):
            idx = i * width + j
            r, g, b = imagem_rgb[idx]
            soma = r * weight_r + g * weight_g + b * weight_b
            linha.append(soma)
        resultado.append(linha)
    return resultado

# --- Exemplo de uso ---

# Imagem 4×4 RGB linearizada
imagem = [
    (1, 5, 3),   (5, 12, 7),  (8, 20, 11), (12, 27, 15),
    (16,35,18),  (20,42,22),  (23,50,26),  (27,57,30),
    (31,60,28),  (26,50,23),  (22,42,20),  (18,35,16),
    (15,27,12),  (11,20,8),   (7,12,5),    (3,5,1)
]

# Pesos do kernel 1×1
weight_r, weight_g, weight_b = 2, 3, 4

# Executa a convolução
saida = convolve_rgb_1x1(imagem, height=4, width=4,
                         weight_r=weight_r,
                         weight_g=weight_g,
                         weight_b=weight_b)

# Exibe o resultado
print("Resultado da convolução 1×1 (2·R + 3·G + 4·B):")
for linha in saida:
    print(linha)

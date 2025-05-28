def convolve_gray_1x1(imagem_gray, height, width, weight):
    """
    Convolução 1×1 para imagem em tons de cinza:
      - imagem_gray: lista linearizada de valores [0…255]
      - height, width: dimensões da imagem
      - weight: peso do kernel 1×1
    """
    resultado = []
    for i in range(height):
        linha = []
        for j in range(width):
            idx   = i * width + j
            pixel = imagem_gray[idx]
            # Aplica o kernel 1×1 (multiplica o pixel pelo peso)
            valor = pixel * weight
            linha.append(valor)
        resultado.append(linha)
    return resultado

# --- Exemplo de uso para a imagem 4×4 fornecida ---
imagem_gray = [
     1,  5,  8, 12,
    16, 20, 23, 27,
    31, 26, 22, 18,
    15, 11,  7,  3
]

# Defina aqui o peso do kernel 1×1; por exemplo, weight = 2
weight = 2

saida = convolve_gray_1x1(imagem_gray, height=4, width=4, weight=weight)

print(f"Resultado da convolução 1x1 (peso={weight}):")
for linha in saida:
    print(linha)

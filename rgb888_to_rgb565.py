# Matriz RGB565
rgb565_matrix = [
    [2211, 10631, 17035, 25455],
    [33906, 42326, 48730, 57150],
    [65436, 54871, 46420, 38000],
    [31596, 23176, 14725, 6305]
]

def rgb565_to_rgb888(valor):
    r5 = (valor >> 11) & 0x1F
    g6 = (valor >> 5) & 0x3F
    b5 = valor & 0x1F

    # Convertendo de volta para RGB888 com interpolação simples
    r8 = (r5 << 3) | (r5 >> 2)
    g8 = (g6 << 2) | (g6 >> 4)
    b8 = (b5 << 3) | (b5 >> 2)

    return (r8, g8, b8)

# Aplicar conversão
rgb888_matrix = []
for linha in rgb565_matrix:
    linha_rgb = [rgb565_to_rgb888(valor) for valor in linha]
    rgb888_matrix.append(linha_rgb)

# Mostrar resultado
for linha in rgb888_matrix:
    print(linha)

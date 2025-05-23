def rgb_to_rgb565(r, g, b):
    """Converte RGB888 para RGB565 (2 bytes)."""
    r5 = (r >> 3) & 0x1F
    g6 = (g >> 2) & 0x3F
    b5 = (b >> 3) & 0x1F
    rgb565 = (r5 << 11) | (g6 << 5) | b5
    return [rgb565 >> 8, rgb565 & 0xFF]  # Retorna em formato big-endian (MSB, LSB)

# Criando uma imagem 4x4 em RGB (RGB888)
# Exemplo: um gradiente simples com valores arbitrários
rgb_image_4x4 = [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
    (130, 140, 150), (160, 170, 180), (190, 200, 210), (220, 230, 240),
    (250, 240, 230), (210, 200, 190), (180, 170, 160), (150, 140, 130),
    (120, 110, 100), (90, 80, 70), (60, 50, 40), (30, 20, 10),
]

# Converter todos os pixels RGB888 para RGB565
rgb565_linear = []
for (r, g, b) in rgb_image_4x4:
    rgb565_linear.extend(rgb_to_rgb565(r, g, b))

print("Imagem 4x4 em RGB565 (linearizada com 2 bytes por pixel):")
print(rgb565_linear)  # 32 elementos: [MSB, LSB, MSB, LSB, ...]

#def rgb_to_rgb565_decimal(r, g, b):
#    """Converte RGB888 para um valor decimal RGB565."""
#    r5 = (r >> 3) & 0x1F     # 5 bits
#    g6 = (g >> 2) & 0x3F     # 6 bits
#    b5 = (b >> 3) & 0x1F     # 5 bits
#    return (r5 << 11) | (g6 << 5) | b5
#
## Matriz 4x4 com valores RGB (R, G, B) arbitrários
#rgb_matrix_4x4 = [
#    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
#    (130, 140, 150), (160, 170, 180), (190, 200, 210), (220, 230, 240),
#    (250, 240, 230), (210, 200, 190), (180, 170, 160), (150, 140, 130),
#    (120, 110, 100), (90, 80, 70), (60, 50, 40), (30, 20, 10),
#]
#
## Converter cada pixel para RGB565 decimal
#rgb565_matrix = [rgb_to_rgb565_decimal(r, g, b) for (r, g, b) in rgb_matrix_4x4]
#
## Mostrar resultado
#print("Matriz 4x4 RGB565 (16 bits por pixel em decimal):")
#for i in range(4):
#    print(rgb565_matrix[i * 4:(i + 1) * 4])
#
#imagem = [
#    2211, 10631, 17035, 25455,
#    33906, 42326, 48730, 57150,
#    65436, 54871, 46420, 38000,
#    31596, 23176, 14725, 6305
#]
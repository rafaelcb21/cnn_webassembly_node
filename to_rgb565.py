def rgb_to_rgb565(r, g, b):
    r5 = r >> 3       # 5 bits
    g6 = g >> 2       # 6 bits
    b5 = b >> 3       # 5 bits
    return (r5 << 11) | (g6 << 5) | b5  # Combina em 16 bits

# Sua imagem RGB
imagem = [ 
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
    (130, 140, 150), (160, 170, 180), (190, 200, 210), (220, 230, 240),
    (250, 240, 230), (210, 200, 190), (180, 170, 160), (150, 140, 130),
    (120, 110, 100), (90, 80, 70), (60, 50, 40), (30, 20, 10),
]



# Converte cada pixel RGB888 para RGB565 (decimal)
imagem_rgb565 = [rgb_to_rgb565(r, g, b) for (r, g, b) in imagem]

# Exibir resultado
print("Imagem convertida para RGB565 (decimal):")
for i in range(4):
    print(imagem_rgb565[i * 4:(i + 1) * 4])

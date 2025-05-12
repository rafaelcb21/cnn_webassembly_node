import struct

# Dimensões
width = 96
height = 96

# Cor desejada em RGB888 (ex: verde puro)
r, g, b = 0, 255, 0  # RGB888 → verde

# Converter RGB888 → RGB565
# RGB565: 5 bits red, 6 bits green, 5 bits blue
r5 = (r >> 3) & 0x1F
g6 = (g >> 2) & 0x3F
b5 = (b >> 3) & 0x1F

# Empacotar para 16 bits
rgb565 = (r5 << 11) | (g6 << 5) | b5

# Gerar bytes da imagem (little-endian)
image_data = bytearray()
for _ in range(width * height):
    image_data += struct.pack('<H', rgb565)  # '<H' = little-endian 16-bit unsigned

# Salvar em arquivo binário
with open("generated_96x96.raw", "wb") as f:
    f.write(image_data)

print("Imagem RGB565 gerada com sucesso: generated_96x96.raw")

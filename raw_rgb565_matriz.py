# Matriz RGB565
rgb565_matrix = [
    [2211, 10631, 17035, 25455],
    [33906, 42326, 48730, 57150],
    [65436, 54871, 46420, 38000],
    [31596, 23176, 14725, 6305]
]

def extract_rgb565_raw(value):
    r = (value >> 11) & 0x1F  # 5 bits (bits 15-11)
    g = (value >> 5) & 0x3F   # 6 bits (bits 10-5)
    b = value & 0x1F          # 5 bits (bits 4-0)
    return (r, g, b)

# Aplicar a extração
rgb_matrix_raw = []
for row in rgb565_matrix:
    row_raw = [extract_rgb565_raw(v) for v in row]
    rgb_matrix_raw.append(row_raw)

# Mostrar resultado
for linha in rgb_matrix_raw:
    print(linha)

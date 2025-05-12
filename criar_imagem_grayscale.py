# Dimensões
width = 96
height = 96

# Nível de cinza desejado (0 = preto, 255 = branco, ex: cinza médio)
gray_value = 128  # Cinza médio

# Criar os bytes da imagem (1 byte por pixel)
image_data = bytearray([gray_value] * (width * height))

# Salvar em arquivo binário
with open("generated_96x96_gray.raw", "wb") as f:
    f.write(image_data)

print("Imagem GRAYSCALE gerada com sucesso: generated_96x96_gray.raw")

# Define imagem real 5x5 (linearizada)
#imagem_real = [
#     1,  2,  3,  4,  5,
#     6,  7,  8,  9, 10,
#    11, 12, 13, 14, 15,
#    16, 17, 18, 19, 20,
#    21, 22, 23, 24, 25
#]
#
## Parâmetros da imagem
#height_real = 5
#width_real = 5
#
## Padding individual
#pad_top = 2
#pad_bottom = 2
#pad_left = 2
#pad_right = 2
#
## Dimensões da imagem com padding
#height_total = pad_top + height_real + pad_bottom  # 9
#width_total = pad_left + width_real + pad_right    # 9
#
## Constrói a imagem com padding (valores reais dentro, 0 fora)
#memoria = [0] * (height_total * width_total)
#
## Copia imagem real para dentro da imagem com padding
#for i in range(height_real):
#    for j in range(width_real):
#        i_pad = i + pad_top
#        j_pad = j + pad_left
#        idx = i_pad * width_total + j_pad
#        idx_real = i * width_real + j
#        memoria[idx] = imagem_real[idx_real]
#
#print(memoria)
#
## Aplica kernel 3x3 com deslocamento linear
#def convolve_with_linear_delta(i, j):
#    # posição central no espaço com padding
#    ii = i + pad_top
#    jj = j + pad_left
#
#    center_index = ii * width_total + jj
#
#    # deslocamentos relativos do kernel 3x3
#    deltas = [
#        -width_total - 1, -width_total, -width_total + 1,
#        -1,               0,            +1,
#        +width_total - 1, +width_total, +width_total + 1
#    ]
#
#    vizinhos = []
#    for delta in deltas:
#        idx = center_index + delta
#
#        # Verificar se o índice está dentro dos limites da imagem real
#        row = idx // width_total
#        col = idx % width_total
#
#        # Verifica se está fora dos limites reais (padding)
#        in_real_image = (
#            pad_top <= row < pad_top + height_real and
#            pad_left <= col < pad_left + width_real
#        )
#
#        valor = memoria[idx] if in_real_image else 0
#        vizinhos.append(valor)
#
#    return vizinhos
#
## Exemplo: aplicar o kernel no pixel (i=0, j=0) da imagem real
#resultado = convolve_with_linear_delta(0, 0)
#
## Exibe os 9 valores acessados com padding simulado
#print("Kernel aplicado em (0,0) com padding 2 em todos os lados:")
#print("Resultado (linha a linha):")
#for i in range(3):
#    print(resultado[i*3:(i+1)*3])

#def convolve_apply_kernel(
#    imagem_real, height_real, width_real,
#    kernel, kernel_h, kernel_w,
#    pad_top, pad_bottom, pad_left, pad_right,
#    stride_h, stride_w
#):
#    # Calcula dimensões da imagem com padding
#    height_total = pad_top + height_real + pad_bottom
#    width_total = pad_left + width_real + pad_right
#
#    # Cria memória linear com padding virtual
#    memoria = [0] * (height_total * width_total)
#
#    # Preenche a memória com a imagem real na posição correta
#    for i in range(height_real):
#        for j in range(width_real):
#            i_pad = i + pad_top
#            j_pad = j + pad_left
#            idx_total = i_pad * width_total + j_pad
#            idx_real = i * width_real + j
#            memoria[idx_total] = imagem_real[idx_real]
#
#    # Calcula quantas vezes o kernel pode ser aplicado
#    out_h = ((height_real + pad_top + pad_bottom - kernel_h) // stride_h) + 1
#    out_w = ((width_real + pad_left + pad_right - kernel_w) // stride_w) + 1
#
#    # Centro e deslocamentos
#    offset_i = 0 if kernel_h % 2 == 0 else -(kernel_h // 2)
#    offset_j = 0 if kernel_w % 2 == 0 else -(kernel_w // 2)
#
#    # Gera deslocamentos lineares delta
#    deltas = []
#    for di in range(kernel_h):
#        for dj in range(kernel_w):
#            rel_di = offset_i + di
#            rel_dj = offset_j + dj
#            delta = rel_di * width_total + rel_dj
#            deltas.append(delta)
#
#    print(deltas)
#    # Aplica kernel com produto soma
#    resultado = []
#    for i_out in range(out_h):
#        linha_resultado = []
#        for j_out in range(out_w):
#            i = i_out * stride_h
#            j = j_out * stride_w
#            ii = i + pad_top
#            jj = j + pad_left
#            center_index = ii * width_total + jj
#
#            soma = 0
#            for k in range(kernel_h * kernel_w):
#                delta = deltas[k]
#                idx = center_index + delta
#                row = idx // width_total
#                col = idx % width_total
#
#                print('idx = center_index + delta', idx, ' = ', center_index, ' + ', delta)
#                print('row = idx // width_total', row, ' = ', idx, ' // ', width_total)
#                print('col = idx % width_total', col, ' = ', idx, ' % ', width_total)
#
#                in_real_image = (
#                    pad_top <= row < pad_top + height_real and
#                    pad_left <= col < pad_left + width_real
#                )
#
#                print(pad_top <= row < pad_top + height_real, pad_left <= col < pad_left + width_real, ' = ', in_real_image)
#
#                valor = memoria[idx] if in_real_image else 0
#                peso = kernel[k]
#                soma += valor * peso
#                print('soma: ',valor, peso, soma)
#                print('====================================')
#
#            linha_resultado.append(soma)
#        resultado.append(linha_resultado)
#
#    return resultado

#def convolve_apply_kernel(
#    imagem_real, height_real, width_real,
#    kernel, kernel_h, kernel_w,
#    pad_top, pad_bottom, pad_left, pad_right,
#    stride_h, stride_w
#):
#    height_total = pad_top + height_real + pad_bottom
#    width_total = pad_left + width_real + pad_right
#
#    out_h = ((height_total - kernel_h) // stride_h) + 1
#    out_w = ((width_total - kernel_w) // stride_w) + 1
#
#    resultado = []
#    for i_out in range(out_h):
#        linha_resultado = []
#        for j_out in range(out_w):
#            i = i_out * stride_h
#            j = j_out * stride_w
#            soma = 0
#
#            for ki in range(kernel_h):
#                for kj in range(kernel_w):
#                    # Coordenadas reais considerando o centro do kernel e deslocamento
#                    row = i + ki
#                    col = j + kj
#
#                    # Verifica se o pixel está dentro da imagem real
#                    if (
#                        pad_top <= row < pad_top + height_real and
#                        pad_left <= col < pad_left + width_real
#                    ):
#                        row_img = row - pad_top
#                        col_img = col - pad_left
#                        idx = row_img * width_real + col_img
#                        valor = imagem_real[idx]
#                    else:
#                        valor = 0
#
#                    # Peso do kernel = kernel[ki * kernel_w + kj]
#                    kidx = ki * kernel_w + kj
#                    peso = kernel[kidx]
#
#                    soma += valor * peso
#
#                    print(f"[i_out={i_out}, j_out={j_out}] row={row}, col={col} -> idx={idx if 'idx' in locals() else 'PAD'} | valor={valor}, peso={peso}, soma={soma}")
#                    print('-----------------------------------------')
#
#            linha_resultado.append(soma)
#        resultado.append(linha_resultado)
#
#    return resultado


def convolve_rgb(imagem_rgb, height_real, width_real,
                 kernel_r, kernel_g, kernel_b,
                 kernel_h, kernel_w,
                 pad_top, pad_bottom, pad_left, pad_right,
                 stride_h, stride_w):

    height_total = pad_top + height_real + pad_bottom
    width_total = pad_left + width_real + pad_right

    out_h = ((height_total - kernel_h) // stride_h) + 1
    out_w = ((width_total - kernel_w) // stride_w) + 1

    resultado = []
    #print(out_h, height_total, kernel_h, stride_h, (height_total - kernel_h) // stride_h)
    for i_out in range(out_h):
        linha_resultado = []
        i = i_out * stride_h
        print('>>> ',i, i_out, stride_h)
        for j_out in range(out_w):
            j = j_out * stride_w

            soma = 0  # resultado final da soma R + G + B

            for ki in range(kernel_h): # vai para o lado
                row = i + ki
                print(pad_top, row, pad_top + height_real, i, j, ki)
                if not (pad_top <= row < pad_top + height_real):
                    print('continue')
                    continue

                row_img = row - pad_top
                row_base = row_img * width_real

                for kj in range(kernel_w):
                    col = j + kj
                    if not (pad_left <= col < pad_left + width_real):
                        continue

                    col_img = col - pad_left
                    idx = row_base + col_img
                    pixel = imagem_rgb[idx]  # pixel é uma tupla (R, G, B)

                    # Aplicar os 3 kernels
                    k_idx = ki * kernel_w + kj
                    soma_r = pixel[0] * kernel_r[k_idx]
                    soma_g = pixel[1] * kernel_g[k_idx]
                    soma_b = pixel[2] * kernel_b[k_idx]

                    soma += soma_r + soma_g + soma_b

            linha_resultado.append(soma)
        resultado.append(linha_resultado)

    return resultado


# Imagem 4x4 (linearizada)
# Imagem 4x4 RGB
imagem = [ 
    (1, 5, 3), (5, 12, 7), (8, 20, 11), (12, 27, 15),
    (16, 35, 18), (20, 42, 22), (23, 50, 26), (27, 57, 30),
    (31, 60, 28), (26, 50, 23), (22, 42, 20), (18, 35, 16),
    (15, 27, 12), (11, 20, 8), (7, 12, 5), (3, 5, 1)
]

# Kernels para R, G e B 2x2
#kernel_b = [7, 2, 1, 5]

# Kernels para R, G e B 3x3
kernel_r = [2, -4, 2, 1, 3, 7, 5 , 2 , 1]
kernel_g = [3, 2, 4, 1, 4, 2, 9, 8, 5]
kernel_b = [7, 2, 4, 1, 5, 7, 2, 3, 9]

# Aplicar convolução com padding bottom/right = 1 (para evitar acesso inválido)
# saida 2x2
#saida = convolve_rgb(
#    imagem_rgb = imagem,
#    height_real = 4,
#    width_real = 4,
#    kernel_r = kernel_r,
#    kernel_g = kernel_g,
#    kernel_b = kernel_b,
#    kernel_h = 2,
#    kernel_w = 2,
#    pad_top = 0,
#    pad_bottom = 1,
#    pad_left = 0,
#    pad_right = 1,
#    stride_h = 1,
#    stride_w = 1
#)

# saida 3x3
saida = convolve_rgb(
    imagem_rgb = imagem,
    height_real = 4,
    width_real = 4,
    kernel_r = kernel_r,
    kernel_g = kernel_g,
    kernel_b = kernel_b,
    kernel_h = 3,
    kernel_w = 3,
    pad_top = 1,
    pad_bottom = 1,
    pad_left = 1,
    pad_right = 1,
    stride_h = 1,
    stride_w = 1
)

# Mostrar resultado
print("Resultado final da convolução RGB somada:")
for linha in saida:
    print(linha)

#resultado =[
#    463, 608, 747, 324,
#    823, 813, 802, 504,
#    687, 532, 398, 262,
#    207, 144, 85, 28
#]

#resultado 3x3
#[940, 1660, 2054, 1475]
#[1863, 2730, 2716, 1639]
#[1719, 2211, 1936, 1004]
#[782, 1087, 810, 398]
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


def convolve_apply_kernel(imagem_real, height_real, width_real,
                                kernel, kernel_h, kernel_w,
                                pad_top, pad_bottom, pad_left, pad_right,
                                stride_h, stride_w):

    height_total = pad_top + height_real + pad_bottom
    width_total = pad_left + width_real + pad_right

    out_h = ((height_total - kernel_h) // stride_h) + 1
    out_w = ((width_total - kernel_w) // stride_w) + 1

    resultado = []

    for i_out in range(out_h):
        linha_resultado = []
        i = i_out * stride_h
        print('i = i_out * stride_h', i, i_out, stride_h)
        for j_out in range(out_w):
            j = j_out * stride_w
            print('j = j_out * stride_w', j, j_out, stride_w)
            soma = 0

            for ki in range(kernel_h):
                row = i + ki
                print('row = i + ki', row, i, ki)
                print('pad_top <= row < pad_top + height_real', pad_top, row, pad_top + height_real, pad_top <= row < pad_top + height_real)
                if not (pad_top <= row < pad_top + height_real):
                    print('continue top')
                    continue  # pula a linha do kernel fora da imagem

                row_img = row - pad_top
                print('row_img = row - pad_top', row_img, row, pad_top)
                row_base = row_img * width_real
                print('row_base = row_img * width_real', row_base, row_img, width_real)
                for kj in range(kernel_w):
                    col = j + kj
                    print('col = j + kj', col, j, kj)
                    print('pad_left <= col < pad_left + width_real', pad_left, col, pad_left + width_real, pad_left <= col < pad_left + width_real)
                    if not (pad_left <= col < pad_left + width_real):
                        print('continue left')
                        continue  # pula coluna fora da imagem

                    col_img = col - pad_left
                    print('col_img = col - pad_left', col_img, col, pad_left)
                    idx = row_base + col_img
                    print('idx = row_base + col_img', idx, row_base, col_img)
                    val = imagem_real[idx]
                    print('val = imagem_real[idx]', val)
                    peso = kernel[ki * kernel_w + kj]
                    print('peso = kernel[ki * kernel_w + kj]', peso, ki, kernel_w, kj, ki * kernel_w + kj, ' = ',kernel[ki * kernel_w + kj])
                    soma += val * peso
                    print('soma += val * peso', soma, val, peso)
                    print('-----------------------------------------')
            print('soma final', soma)
            print('====================================')

            linha_resultado.append(soma)
        resultado.append(linha_resultado)

    return resultado

# Imagem 5x5 (linearizada)
imagem = [
     1, 2, 3, 4, 
     5, 6, 7, 8, 
     9, 10, 11, 12, 
     13, 14, 15, 16
]

# Kernel 3×3: detector de borda simples
kernel = [
    2, -4,
    1, 3
]

# Aplicar convolução com padding = 1 (para manter tamanho), stride = 1
saida = convolve_apply_kernel(
    imagem_real = imagem,
    height_real = 4,
    width_real = 4,
    kernel = kernel,
    kernel_h = 2,
    kernel_w = 2,
    pad_top = 0,
    pad_bottom = 1,
    pad_left = 0,
    pad_right = 1,
    stride_h = 1,
    stride_w = 1
)

# Mostrar resultado
print("Resultado final da convolução:")
for linha in saida:
    print(linha)

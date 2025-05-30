const fs = require('fs');

let currentInstance;

(async () => {
    const wasmBuffer = fs.readFileSync("grayscale_3x3_valid.wasm");
    const wasmModule = await WebAssembly.instantiate(wasmBuffer, {
        env: {
            log: (value) => console.log("LOG:", value),
        }
    });

    currentInstance = wasmModule.instance;

    // Enviar a imagem
    const memory = new Uint8Array(currentInstance.exports.memory.buffer);

    memory.set([
         1,  5,  8, 12,
        16, 20, 23, 27,
        31, 26, 22, 18,
        15, 11,  7,  3
    ], 0);

    const stride_h = 1;
    const stride_w = 1;

    x = currentInstance.exports.convolve_grayscale_3x3_valid(
        0,   // ptr para imagem
        4,   // height da imagem
        4,   // width da imagem
        stride_h,   // heigth do stride
        stride_w,   // width do stride
        16,  // ponteiro de saida do resultado apos a convolução

        2,   // kernel indice 00
        -4,  // kernel indice 01
        2,   // kernel indice 02
        1,   // kernel indice 10
        3,   // kernel indice 11
        7,   // kernel indice 12
        5,   // kernel indice 20
        2,   // kernel indice 21
        1,   // kernel indice 22
    );

    const decimalDump = Array.from(memory); // já retorna os valores decimais
    fs.writeFileSync('./memory_bytes_decimal.json', JSON.stringify(decimalDump, null, 2));

    // Carrega o conteúdo do JSON salvo anteriormente
    const memoryBytes = JSON.parse(fs.readFileSync('./memory_bytes_decimal.json', 'utf-8'));

    const height   = 4;
    const width    = 4;
    const kernel_h = 3;
    const kernel_w = 3;

    out_h = Math.floor((height  - kernel_h) / stride_h) + 1;
    out_w = Math.floor((width   - kernel_w) / stride_w) + 1;

    // Define o intervalo desejado
    const start = 16;
    const end = start + out_h * out_w * 4;

    // Extrai os bytes do intervalo
    const selectedBytes = memoryBytes.slice(start, end);

    // Processa de 4 em 4 bytes
    const results = [];
    for (let i = 0; i < selectedBytes.length; i += 4) {
        // Pega os 4 bytes e inverte a ordem (little endian → big endian)
        const group = selectedBytes.slice(i, i + 4).reverse();

        // Converte os 4 bytes para um único número de 32 bits (signed)
        const value =
            (group[0] << 24) |
            (group[1] << 16) |
            (group[2] << 8) |
            (group[3] << 0);

        // Ajusta sinal (corrige para números negativos caso necessário)
        const signedValue = value | 0;

        results.push(signedValue);
    }

    // Mostra os valores convertidos
    console.log("Resultados reconstruídos (int32):");
    console.log(results);
})();

//1x1 hxw
//[ 464, 472, 365, 292 ]

//2x2 hxw
//[ 464 ]

//1x2 hxw
//[ 464, 365 ]

//2x1 hxw
//[ 464, 472 ]
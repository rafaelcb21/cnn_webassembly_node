const fs = require('fs');

let currentInstance;

(async () => {
    const wasmBuffer = fs.readFileSync("rgb565_3x3_same.wasm");
    const wasmModule = await WebAssembly.instantiate(wasmBuffer, {
        env: {
            log: (value) => console.log("LOG:", value),
        }
    });

    currentInstance = wasmModule.instance;

    // Enviar a imagem
    const memory = new Uint8Array(currentInstance.exports.memory.buffer);

    const values16 = [
        2211, 10631, 17035, 25455,
        33906, 42326, 48730, 57150,
        65436, 54871, 46420, 38000,
        31596, 23176, 14725, 6305,
    ];

    let offset = 0;  // índice inicial na memória

    for (const val of values16) {
        memory[offset] = (val >> 8) & 0xFF; // MSB primeiro
        memory[offset + 1] = val & 0xFF;    // LSB depois
        offset += 2;
    }

    const stride_h = 2;
    const stride_w = 1;

    x = currentInstance.exports.convolve_rgb565_3x3_same(
        0,   // ptr para imagem
        4,   // height da imagem
        4,   // width da imagem
        1,   // padding top
        1,   // padding bottom
        1,   // padding left
        1,   // padding right
        stride_h,   // heigth do stride
        stride_w,   // width do stride
        32,  // ponteiro de saida do resultado apos a convolução

        2,   // kernel indice 00 RED
        -4,  // kernel indice 01 RED
        2,   // kernel indice 02 RED
        1,   // kernel indice 10 RED
        3,   // kernel indice 11 RED
        7,   // kernel indice 12 RED
        5,   // kernel indice 20 RED
        2,   // kernel indice 21 RED
        1,   // kernel indice 22 RED

        3,   // kernel indice 00 GREEN
        2,   // kernel indice 01 GREEN
        4,   // kernel indice 02 GREEN
        1,   // kernel indice 10 GREEN
        4,   // kernel indice 11 GREEN
        2,   // kernel indice 12 GREEN
        9,   // kernel indice 20 GREEN
        8,   // kernel indice 21 GREEN
        5,   // kernel indice 22 GREEN

        7,   // kernel indice 00 BLUE
        2,   // kernel indice 01 BLUE
        4,   // kernel indice 02 BLUE
        1,   // kernel indice 10 BLUE
        5,   // kernel indice 11 BLUE
        7,   // kernel indice 12 BLUE
        2,   // kernel indice 20 BLUE
        3,   // kernel indice 21 BLUE
        9,   // kernel indice 22 BLUE
    );

    const decimalDump = Array.from(memory); // já retorna os valores decimais
    fs.writeFileSync('./memory_bytes_decimal.json', JSON.stringify(decimalDump, null, 2));

    // Carrega o conteúdo do JSON salvo anteriormente
        const memoryBytes = JSON.parse(fs.readFileSync('./memory_bytes_decimal.json', 'utf-8'));
    
        const height   = 4;
        const width    = 4;

        const out_h = Math.floor((height  + stride_h - 1) / stride_h);
        const out_w = Math.floor((width   + stride_w - 1) / stride_w);

        // Define o intervalo desejado
        const start = 32;
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
//[
//    940, 1660, 2054, 1475,
//   1863, 2730, 2716, 1639,
//   1719, 2211, 1936, 1004,
//    782, 1087,  810,  398
//]

//2x2
//[ 940, 2054, 1719, 1936 ]

//1x2
//[
//    940, 2054, 1863,
//   2716, 1719, 1936,
//    782,  810
//]

//2x1
//[
//    940, 1660, 2054,
//   1475, 1719, 2211,
//   1936, 1004
//]
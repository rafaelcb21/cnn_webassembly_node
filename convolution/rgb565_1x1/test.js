const fs = require('fs');

let currentInstance;

(async () => {
    const wasmBuffer = fs.readFileSync("rgb565_1x1.wasm");
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

    x = currentInstance.exports.convolve_rgb565_1x1(
        0,   // ptr para imagem
        4,   // height da imagem
        4,   // width da imagem
        1,   // heigth do stride
        1,   // width do stride
        32,  // ponteiro de saida do resultado apos a convolução
        2,   // kernel indice 00 RED
        3,   // kernel indice 00 GREEN
        4    // kernel indice 00 BLUE
    );

    const decimalDump = Array.from(memory); // já retorna os valores decimais
    fs.writeFileSync('./memory_bytes_decimal.json', JSON.stringify(decimalDump, null, 2));

    // Carrega o conteúdo do JSON salvo anteriormente
    const memoryBytes = JSON.parse(fs.readFileSync('./memory_bytes_decimal.json', 'utf-8'));

    // Define o intervalo desejado
    const start = 32;
    const end = 96; // índice 95 incluído (inclusive)

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

//[ VERIFICAR SE ESTA CERTO OU ERRADO
//    29,  74, 120, 165, 209,
//   254, 300, 345, 354, 294,
//   250, 205, 159, 114,  70,
//    25
//]